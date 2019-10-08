module Node.Websocket.Aff.Server where

import Prelude

import Effect (Effect)
import Node.Websocket.Aff.Types (CloseDescription, CloseReason, ServerConfig, WSConnection, WSRequest, WSServer)

foreign import newWebsocketServer :: ServerConfig -> Effect WSServer

type RequestCallback = WSRequest -> Effect Unit

foreign import onRequest :: WSServer -> RequestCallback -> Effect Unit

type ConnectCallback = WSConnection -> Effect Unit

foreign import onConnect :: WSServer -> ConnectCallback -> Effect Unit

type CloseCallback =
  WSConnection -> CloseReason -> CloseDescription -> Effect Unit

foreign import onClose :: WSServer -> CloseCallback -> Effect Unit

foreign import shutdown :: WSServer -> Effect Unit