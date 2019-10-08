module Node.Websocket.Aff where

import Prelude

import Data.Either (Either)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Exception (Error)
import Node.Buffer (Buffer)
import Node.HTTP as HTTP
import Node.Websocket.Aff.Client as Client
import Node.Websocket.Aff.Connection as Conn
import Node.Websocket.Aff.Frame as Frame
import Node.Websocket.Aff.Request as Req
import Node.Websocket.Aff.Server as Server
import Node.Websocket.Aff.Types (BinaryFrame, CloseDescription, CloseReason, ErrorDescription, TextFrame, WSClient, WSConnection, WSFrame, WSRequest, WSServer)
import Node.Websocket.Aff.Types as Types

class On (evt :: Event) obj callback out | evt -> callback obj out where
  on :: forall proxy. proxy evt -> obj -> callback -> out

foreign import kind Event

data EventProxy (e :: Event) = EventProxy

foreign import data ConnectionMessage :: Event

foreign import data ConnectionFrame :: Event

foreign import data ConnectionClose :: Event

foreign import data ConnectionError :: Event

foreign import data ConnectionPing :: Event

foreign import data ConnectionPong :: Event

foreign import data RequestAccepted :: Event

foreign import data RequestRejected :: Event

foreign import data Request :: Event

foreign import data Connect :: Event

foreign import data Close :: Event

foreign import data ClientConnect :: Event

foreign import data ClientConnectFailed :: Event

foreign import data HttpResponse :: Event

instance connectionOnMessage
  :: On ConnectionMessage WSConnection (Either TextFrame BinaryFrame -> Aff Unit) (Aff Unit)
  where
    on _ = Conn.onMessage

instance connectionOnFrame
  :: On ConnectionFrame WSConnection (WSFrame -> Effect Unit) (Effect Unit)
  where
    on _ = Conn.onFrame

instance connectionOnClose
  :: On ConnectionClose WSConnection (CloseReason -> CloseDescription -> Effect Unit) (Effect Unit)
  where
    on _ = Conn.onClose

instance connectionOnError
  :: On ConnectionError WSConnection (Error -> Effect Unit) (Effect Unit)
  where
    on _ = Conn.onError

instance connectionOnPing
  :: On ConnectionPing WSConnection (Buffer -> Effect Unit -> Effect Unit) (Effect Unit)
  where
    on _ = Conn.onPing

instance connectionOnPong
  :: On ConnectionPong WSConnection (Buffer -> Effect Unit) (Effect Unit)
  where
    on _ = Conn.onPong

instance requestOnAccepted
  :: On RequestAccepted WSRequest (WSConnection -> Effect Unit) (Effect Unit)
  where
    on _ = Req.onRequestAccepted

instance requestOnRejected
  :: On RequestRejected WSRequest (Effect Unit) (Effect Unit)
  where
    on _ = Req.onRequestRejected

instance serverOnRequest
  :: On Request WSServer (WSRequest -> Effect Unit) (Effect Unit)
  where
    on _ = Server.onRequest

instance serverOnConnect
  :: On Connect WSServer (WSConnection -> Effect Unit) (Effect Unit)
  where
    on _ = Server.onConnect

instance serverOnClose
  :: On Close WSServer (WSConnection -> CloseReason -> CloseDescription -> Effect Unit) (Effect Unit)
  where
    on _ = Server.onClose

instance clientOnConnect
  :: On ClientConnect WSClient (WSConnection -> Effect Unit) (Effect Unit)
  where
    on _ = Client.onConnect

instance clientOnConnectFailed
  :: On ClientConnectFailed WSClient (ErrorDescription -> Effect Unit) (Effect Unit)
  where
    on _ = Client.onConnectFailed

instance clientOnHttpResponse
  :: On HttpResponse WSClient (HTTP.Response -> WSClient -> Effect Unit) (Effect Unit)
  where
    on _ = Client.onHttpResponse

foreign import kind Property 

foreign import data Fin :: Property

foreign import data Rsv1 :: Property

foreign import data Rsv2 :: Property

foreign import data Rsv3 :: Property

foreign import data Mask :: Property

foreign import data OpCode :: Property

foreign import data Length :: Property

foreign import data BinaryPayload :: Property

data PropertyProxy (p :: Property) = PropertyProxy

class Get (prop :: Property) obj val | prop -> obj val where
  get :: forall proxy. proxy prop -> obj -> val

class Set (prop :: Property) obj val out | prop -> obj val out where
  set :: forall proxy. proxy prop -> obj -> val -> out

instance frameGetFin
  :: Get Fin WSFrame Boolean
  where
    get _ = Frame.getFin

instance frameSetFin
  :: Set Fin WSFrame Boolean (Effect Unit)
  where
    set _ = Frame.setFin

instance frameGetRsv1
  :: Get Rsv1 WSFrame Boolean
  where
    get _ = Frame.getRsv1

instance frameSetRsv1
  :: Set Rsv1 WSFrame Boolean (Effect Unit)
  where
    set _ = Frame.setRsv1

instance frameGetRsv2
  :: Get Rsv2 WSFrame Boolean
  where
    get _ = Frame.getRsv2

instance frameSetRsv2
  :: Set Rsv2 WSFrame Boolean (Effect Unit)
  where
    set _ = Frame.setRsv2

instance frameGetRsv3
  :: Get Rsv3 WSFrame Boolean
  where
    get _ = Frame.getRsv3

instance frameSetRsv3
  :: Set Rsv3 WSFrame Boolean (Effect Unit)
  where
    set _ = Frame.setRsv3

instance frameGetMask
  :: Get Mask WSFrame Int
  where
    get _ = Frame.getMask

instance frameSetMask
  :: Set Mask WSFrame Int (Effect Unit)
  where
    set _ = Frame.setMask

instance frameGetOpCode
  :: Get OpCode WSFrame Types.OpCode
  where
    get _ = Frame.getOpCode

instance frameSetOpCode
  :: Set OpCode WSFrame Types.OpCode (Effect Unit)
  where
    set _ = Frame.setOpCode

instance frameGetLength
  :: Get Length WSFrame Int
  where
    get _ = Frame.getLength

instance frameGetBinaryPayload
  :: Get BinaryPayload WSFrame Buffer
  where
    get _ = Frame.getBinaryPayload

instance frameSetBinaryPayload
  :: Set BinaryPayload WSFrame Buffer (Effect Unit)
  where
    set _ = Frame.setBinaryPayload
