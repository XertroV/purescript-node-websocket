module Test.Main where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (for_, traverse_)
import Data.FoldableWithIndex (forWithIndex_)
import Data.List (List(Nil), fromFoldable, length, range, (!!), (:))
import Data.Maybe (Maybe(..), fromJust)
import Data.Nullable (Nullable, notNull, toNullable)
import Data.Set as Set
import Data.String (Pattern(..), split)
import Data.Traversable (sequence)
import Data.Tuple (Tuple(..), fst, snd)
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, error, launchAff_, throwError)
import Effect.Aff.AVar (AVar)
import Effect.Aff.AVar as AVar
import Effect.Class (liftEffect)
import Effect.Console (log) as C
import Effect.Unsafe (unsafePerformEffect)
import Node.HTTP (listen)
import Node.HTTP as HTTP
import Node.Websocket.Aff (ClientConnect, Connect, ConnectionClose, ConnectionMessage, EventProxy(EventProxy), Request, on)
import Node.Websocket.Aff.Client (connect, defaultConnectOptions, newWebsocketClient)
import Node.Websocket.Aff.Connection (remoteAddress, sendMessage, sendUTF)
import Node.Websocket.Aff.Connection as Connection
import Node.Websocket.Aff.Request (accept, origin)
import Node.Websocket.Aff.Server (newWebsocketServer, shutdown)
import Node.Websocket.Aff.Types (TextFrame(..), WSClient, WSConnection, defaultClientConfig, defaultServerConfig)
import Partial.Unsafe (unsafePartial)
import Test.QuickCheck (Result(..), assertEquals)
import Unsafe.Coerce (unsafeCoerce)

data AppState


modifyAVar :: forall a. AVar a -> (a -> a) -> Aff Unit
modifyAVar v f = do
    inner <- AVar.take v
    AVar.put (f inner) v

modifyAVar_ :: forall a. AVar a -> (a -> Aff a) -> Aff Unit
modifyAVar_ v f = do
    AVar.take v >>= f >>= flip AVar.put v
    
withAVar_ :: forall a. AVar a -> (a -> Aff Unit) -> Aff Unit
withAVar_ v f = AVar.read v >>= f

port = 2718

-- | Routes incoming messages to all clients except the one that sent it, and sends
-- | message history to new connections.
main :: Effect Unit
main = launchAff_ do
  httpServer <- liftEffect $ HTTP.createServer \ _ _ -> (C.log "Server created")
  liftEffect $ listen
    httpServer
    {hostname: "localhost", port, backlog: Nothing} do
      C.log "Server now listening"

  log "Creating server..."
  wsServer <- liftEffect $ newWebsocketServer (defaultServerConfig httpServer)

  log "Done. Initializing AVars..."
  clientsRef <- AVar.new Set.empty
  historyRef <- AVar.new Nil

  log "Done. Setting onRequest handler..."
  liftEffect $ on request wsServer \ req -> launchAff_ do
    let remoteName = show (origin req)
    log do
      "New connection from: " <> remoteName

    conn <- liftEffect $ accept req (toNullable Nothing) (origin req)
    modifyAVar clientsRef (Set.insert conn)

    log "New connection accepted"

    -- history <- Array.freeze historyRef
    -- sending a batched history requires client-side decoding support
    
    withAVar_ historyRef \hist -> do
      _ <- sequence $ (liftEffect <<< sendUTF conn) <$> hist
      pure unit
    --traverse_ (map $ sendUTF conn) historyRef

    on message conn \ msg -> do
      case msg of
        Left (TextFrame {utf8Data}) -> do
          hist <- AVar.take historyRef
          AVar.put (utf8Data : hist) historyRef
          log ("Received message (" <> remoteName <> "): " <> utf8Data)
        Right _ -> pure unit
          
      -- hist <- AVar.read historyRef
      -- _ <- sequence $ (log <<< show) <$> hist

      withAVar_ clientsRef \clients -> do
        log $ "Clients in handler for " <> remoteName <> " : " <> show (Set.size clients)
        _ <- sequence $ (Set.toUnfoldable clients :: Array _) <#> \client -> do
          when (conn /= client) do
            log $ "sending message to " <> remoteName <> " : " <> show (case msg of
              Left (TextFrame {utf8Data}) -> utf8Data
              Right _ -> "<< binary data >>")
            liftEffect $ sendMessage client msg
            
        pure unit

    liftEffect $ on close conn \ _ _ -> launchAff_ do
      log ("Peer disconnected " <> remoteAddress conn)
      modifyAVar clientsRef \clients -> Set.delete conn clients
      pure unit
  
  log "Done."

  let expected = fromFoldable [Tuple "c1" "1", Tuple "c2" "2", Tuple "c1" "3", Tuple "c3" "4", Tuple "c2" "5"]
  state <- AVar.new { last: -1, dones: 0, connections: 0 }

  c1 <- mkClient "c1" state expected
  c2 <- mkClient "c2" state expected
  c3 <- mkClient "c3" state expected

  let nClients = 3

  until_ (\_ -> do
    state_ <- AVar.read state
    -- log $ "state | connections: " <> show state_.connections <> " | dones: " <> show state_.dones
    pure $ state_.dones == nClients
  ) (\_ -> sleep $ 100.0)

  log "Completed test."
  liftEffect $ shutdown wsServer
  log "Shutdown ws server"
  liftEffect $ HTTP.close httpServer (pure unit)
  log "Shutdown http server"

  where
    close = EventProxy :: EventProxy ConnectionClose
    message = EventProxy :: EventProxy ConnectionMessage
    request = EventProxy :: EventProxy Request

    until_ :: (Unit -> Aff Boolean) -> (Unit -> Aff Unit) -> Aff Unit
    until_ check' run' = do
      isDone <- check' unit
      if not isDone
        then do
          run' unit
          until_ check' run'
        else pure unit

    -- mkClient :: String -> _ -> Aff WSClient
    mkClient name state expected = do
      lastMsgIx <- AVar.new (-1)
      client <- liftEffect $ newWebsocketClient defaultClientConfig
      liftEffect $ connect client ("ws://localhost:" <> show port) $ defaultConnectOptions { origin = notNull name }
      _ <- liftEffect $ on (EventProxy :: EventProxy ClientConnect) client \ conn -> launchAff_ do
        modifyAVar state \s@{connections} -> s { connections = connections + 1 }
        log $ show name <> ": connected to server"
        withAVar_ state \s -> log $ "State: " <> show s
        mkClientOnConn name conn state lastMsgIx expected
        when ((expected !! 0 <#> fst # fjup) == name) do
          liftEffect $ sendUTF conn $ name <> "|" <> (expected !! 0 <#> snd # fjup)
          modifyAVar lastMsgIx \i -> 0
      pure client

    mkClientOnConn :: String -> WSConnection -> _ -> _ -> _ -> Aff Unit
    mkClientOnConn name conn state lastMsgIx expected = do
      clog name $ "connected"
      on message conn \ msg -> do
        case msg of
          Left (TextFrame {utf8Data}) -> do
            case (split (Pattern "|") utf8Data # fromFoldable) of
              senderName : senderMsg : nil -> do
                clog name $ "from: " <> senderName <> " got: '" <> senderMsg <> "'"
                expectedIx <- (+) 1 <$> AVar.read lastMsgIx
                clog name $ "expected match: " <> show (fjup $ expected !! expectedIx)
                let (Tuple expSender expMsg) = fjup $ expected !! expectedIx
                assertEq expSender senderName
                assertEq expMsg senderMsg
                clog name $ "expected matched"
                modifyAVar lastMsgIx \_ -> expectedIx
                let nextIx = expectedIx + 1
                if length expected == nextIx
                  then do
                    clog name $ "got all expected, shuting down"
                    modifyAVar state \s@{dones} -> s { dones = dones + 1 }
                    liftEffect $ Connection.close conn
                  else if (expected !! nextIx # fjup # fst) /= name
                    then do
                      clog name $ "did not match next (which was: " <> show (fjup $ expected !! nextIx) <> ")"
                    else do
                      clog name $ "will send next msg"
                      sleep 10.0
                      liftEffect $ sendUTF conn $ name <> "|" <> (expected !! nextIx <#> snd # fjup)
                      modifyAVar lastMsgIx \i -> i + 1
                      clog name $ "sent msg"
                      if length expected == nextIx + 1
                        then do
                          clog name $ "sent last expected, shuting down"
                          modifyAVar state \s@{dones} -> s { dones = dones + 1 }
                          liftEffect $ Connection.close conn
                        else
                          clog name $ "waiting for next msg"
                pure unit
              _ -> throwError $ error $ "Got a msg that didn't match expected format: " <> show utf8Data
          Right e -> throwError $ error $ "Got a msg that wasn't utf8: " <> unsafeCoerce e
      sleep 10.0

    log :: String -> Aff Unit
    log = liftEffect <<< C.log

    clog name msg = log $ "CLIENT | " <> name <> " | " <> msg

    sleep :: Number -> Aff Unit
    sleep n = delay $ Milliseconds n

    assertEq :: forall a. Eq a => Show a => a -> a -> Aff Unit
    assertEq a b = do 
      case assertEquals a b of
        Success -> pure unit
        Failed s -> throwError $ error s


fjup :: forall a. Maybe a -> a
fjup a = (unsafePartial fromJust) a