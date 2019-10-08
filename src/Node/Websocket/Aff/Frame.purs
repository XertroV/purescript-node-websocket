module Node.Websocket.Aff.Frame
  ( newWebsocketFrame
  , getFin, setFin
  , getRsv1, setRsv1
  , getRsv2, setRsv2
  , getRsv3, setRsv3
  , getMask, setMask
  , getOpCode, setOpCode
  , getLength
  , getBinaryPayload, setBinaryPayload
  ) where

import Prelude

import Effect (Effect)
import Node.Buffer (Buffer)
import Node.Websocket.Aff.Types (OpCode(..), WSFrame)

foreign import newWebsocketFrame :: Effect WSFrame

foreign import unsafeGet :: forall a. WSFrame -> String -> a

foreign import unsafeSet :: forall e a. WSFrame -> String -> a -> Effect Unit

getFin :: WSFrame -> Boolean
getFin = unsafeGet <@> "fin"

setFin :: WSFrame -> Boolean -> Effect Unit
setFin = unsafeSet <@> "fin"

getRsv1 :: WSFrame -> Boolean
getRsv1 = unsafeGet <@> "rsv1"

setRsv1 :: WSFrame -> Boolean -> Effect Unit
setRsv1 = unsafeSet <@> "rsv1"

getRsv2 :: WSFrame -> Boolean
getRsv2 = unsafeGet <@> "rsv2"

setRsv2 :: WSFrame -> Boolean -> Effect Unit
setRsv2 = unsafeSet <@> "rsv2"

getRsv3 :: WSFrame -> Boolean
getRsv3 = unsafeGet <@> "rsv3"

setRsv3 :: WSFrame -> Boolean -> Effect Unit
setRsv3 = unsafeSet <@> "rsv3"

getMask :: WSFrame -> Int
getMask = unsafeGet <@> "mask"

setMask :: WSFrame -> Int -> Effect Unit
setMask = unsafeSet <@> "mask"

getOpCode :: WSFrame -> OpCode
getOpCode f = case unsafeGet f "opcode" of
  0 -> Continuation
  1 -> Text
  2 -> Binary
  8 -> Close
  9 -> Ping
  _ -> Pong

setOpCode :: WSFrame -> OpCode -> Effect Unit
setOpCode f o = unsafeSet f "opcode" case o of
  Continuation -> 0
  Text -> 1
  Binary -> 2
  Close -> 8
  Ping -> 9
  Pong -> 10

getLength :: WSFrame -> Int
getLength = unsafeGet <@> "length"

getBinaryPayload :: WSFrame -> Buffer
getBinaryPayload = unsafeGet <@> "binaryPayload"

setBinaryPayload :: WSFrame -> Buffer -> Effect Unit
setBinaryPayload = unsafeSet <@> "binaryPayload"