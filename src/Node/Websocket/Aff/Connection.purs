module Node.Websocket.Aff.Connection
  ( closeDescription
  , closeReasonCode
  , protocol
  , remoteAddress
  , webSocketVersion
  , connected
  , closeWithReason
  , close
  , drop
  , sendUTF
  , sendBytes
  , sendMessage
  , ping
  , pong
  , sendFrame
  , MessageCallback
  , onMessage
  , FrameCallback
  , onFrame
  , ErrorCallback
  , onError
  , CloseCallback
  , onClose
  , PingCallback
  , onPing
  , PongCallback
  , onPong
  ) where

import Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either (Either(..))
import Data.Nullable (Nullable)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Exception (Error)
import Node.Buffer (Buffer)
import Node.Websocket.Aff.Types (BinaryFrame(..), CloseDescription, CloseReason, TextFrame(..), WSConnection, WSFrame)

foreign import closeDescription :: WSConnection -> Nullable CloseDescription

foreign import closeReasonCode :: WSConnection -> CloseReason

-- TODO: implement socket
-- Problem: there's no bindings to node's net module

foreign import protocol :: WSConnection -> String

foreign import remoteAddress :: WSConnection -> String

foreign import webSocketVersion :: WSConnection -> Number

foreign import connected :: WSConnection -> Boolean

foreign import closeWithReason :: WSConnection -> CloseReason -> CloseDescription -> Effect Unit

foreign import close :: WSConnection -> Effect Unit

-- | See https://github.com/theturtle32/WebSocket-Node/blob/master/docs/WebSocketConnection.md#dropreasoncode-description
foreign import drop :: WSConnection -> CloseReason -> CloseDescription -> Effect Unit

foreign import sendUTF :: WSConnection -> String -> Effect Unit

foreign import sendBytes :: WSConnection -> Buffer -> Effect Unit

sendMessage :: WSConnection -> Either TextFrame BinaryFrame -> Effect Unit
sendMessage conn = case _ of
  Left (TextFrame msg) -> sendUTF conn msg.utf8Data
  Right (BinaryFrame msg) -> sendBytes conn msg.binaryData

foreign import ping :: WSConnection -> Buffer -> Effect Unit

foreign import pong :: WSConnection -> Buffer -> Effect Unit

foreign import sendFrame :: WSConnection -> WSFrame -> Effect Unit

type MessageCallback = Either TextFrame BinaryFrame -> Aff Unit
type MessageCallbackImpl = Either TextFrame BinaryFrame -> Effect Unit

foreign import onMsgImpl :: forall a b. (a -> Either a b) -> (b -> Either a b) -> WSConnection -> MessageCallbackImpl -> Effect (Promise Unit)
-- foreign import onMessageImpl :: forall a b. (a -> Either a b) -> (b -> Either a b) -> WSConnection -> MessageCallback -> Effect Unit

onMessage :: forall a. WSConnection -> MessageCallback -> Aff Unit
onMessage conn cb = onMsgImpl Left Right conn (\a -> launchAff_ $ cb a) # liftEffect >>= Promise.toAff

type FrameCallback = WSFrame -> Effect Unit

foreign import onFrame :: WSConnection -> FrameCallback -> Effect Unit

type CloseCallback = CloseReason -> CloseDescription -> Effect Unit

foreign import onClose :: WSConnection -> CloseCallback -> Effect Unit

type ErrorCallback = Error -> Effect Unit

foreign import onError :: WSConnection -> ErrorCallback -> Effect Unit

type PingCallback = Buffer -> Effect Unit -> Effect Unit

foreign import onPing :: WSConnection -> PingCallback -> Effect Unit

type PongCallback = Buffer -> Effect Unit

foreign import onPong :: WSConnection -> PongCallback -> Effect Unit