module Node.Websocket.Aff.Connection
  ( closeDescription
  , closeReasonCode
  , protocol
  , remoteAddress
  , webSocketVersion
  , connected
  , closeWithReason
  , close
  , close_
  , drop
  , sendUTF
  , sendUTF_
  , sendBytes
  , sendMessage
  , ping
  , pong
  , sendFrame
  , MessageCallback
  , onMessage
  , onMessage_
  , FrameCallback
  , onFrame
  , onFrame_
  , ErrorCallback
  , onError
  , onError_
  , CloseCallback
  , onClose
  , onClose_
  , PingCallback
  , onPing
  , onPing_
  , PongCallback
  , onPong
  , onPong_
  ) where

import Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either (Either(..))
import Data.Nullable (Nullable)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Compat (EffectFnAff(..), fromEffectFnAff)
import Effect.Class (liftEffect)
import Effect.Exception (Error)
import Node.Buffer (Buffer)
import Node.Websocket.Aff.Internal (unimpl0, unimpl2)
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
foreign import closeImpl :: WSConnection -> EffectFnAff Unit
close_ :: WSConnection -> Aff Unit
close_ = fromEffectFnAff <<< closeImpl

-- | See https://github.com/theturtle32/WebSocket-Node/blob/master/docs/WebSocketConnection.md#dropreasoncode-description
foreign import drop :: WSConnection -> CloseReason -> CloseDescription -> Effect Unit

foreign import sendUTF :: WSConnection -> String -> Effect Unit
foreign import sendUTFImpl :: WSConnection -> String -> EffectFnAff Unit

sendUTF_ :: WSConnection -> String -> Aff Unit
sendUTF_ conn msg = unimpl0 (\_ -> sendUTFImpl conn msg) (pure unit)

foreign import sendBytes :: WSConnection -> Buffer -> Effect Unit
foreign import sendBytesImpl :: WSConnection -> Buffer -> EffectFnAff Unit
sendBytes_ :: WSConnection -> Buffer -> Aff Unit
sendBytes_ conn buf = unimpl0 (\_ -> sendBytesImpl conn buf) (pure unit)

sendMessage :: WSConnection -> Either TextFrame BinaryFrame -> Aff Unit
sendMessage conn = case _ of
  Left (TextFrame msg) -> sendUTF_ conn msg.utf8Data
  Right (BinaryFrame msg) -> sendBytes_ conn msg.binaryData

foreign import ping :: WSConnection -> Buffer -> Effect Unit

foreign import pong :: WSConnection -> Buffer -> Effect Unit

foreign import sendFrame :: WSConnection -> WSFrame -> Effect Unit

type MessageCallback = Either TextFrame BinaryFrame -> Aff Unit
type MessageCallbackImpl = Either TextFrame BinaryFrame -> Effect Unit

foreign import onMsgImpl :: forall a b. (a -> Either a b) -> (b -> Either a b) -> WSConnection -> MessageCallbackImpl -> Effect (Promise Unit)
foreign import onMessageImpl :: forall a b. (a -> Either a b) -> (b -> Either a b) -> WSConnection -> MessageCallback -> Effect Unit

onMessage :: WSConnection -> MessageCallback -> Aff Unit
onMessage conn cb = onMsgImpl Left Right conn (\a -> launchAff_ $ cb a) # liftEffect >>= Promise.toAff

onMessage_ = onMessage

type FrameCallback = WSFrame -> Effect Unit

foreign import onFrame :: WSConnection -> FrameCallback -> Effect Unit

onFrame_ = onFrame

type CloseCallback = CloseReason -> CloseDescription -> Effect Unit
type CloseCallback' = CloseReason -> CloseDescription -> Aff Unit

foreign import onClose :: WSConnection -> CloseCallback -> Effect Unit
foreign import onCloseImpl :: WSConnection -> CloseCallback -> EffectFnAff Unit
onClose_ :: WSConnection -> CloseCallback' -> Aff Unit
onClose_ conn cb = unimpl2 (onCloseImpl conn) cb


type ErrorCallback = Error -> Effect Unit

foreign import onError :: WSConnection -> ErrorCallback -> Effect Unit

onError_ = onError

type PingCallback = Buffer -> Effect Unit -> Effect Unit

foreign import onPing :: WSConnection -> PingCallback -> Effect Unit

onPing_ = onPing

type PongCallback = Buffer -> Effect Unit

foreign import onPong :: WSConnection -> PongCallback -> Effect Unit

onPong_ = onPong