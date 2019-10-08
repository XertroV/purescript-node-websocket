module Node.Websocket.Aff.Server where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Node.Websocket.Aff.Types (CloseDescription, CloseReason, ServerConfig, WSConnection, WSRequest, WSServer)

foreign import newWebsocketServer :: ServerConfig -> Effect WSServer

foreign import newWsServerImpl :: ServerConfig -> EffectFnAff WSServer

newWsServer :: ServerConfig -> Aff WSServer
newWsServer = fromEffectFnAff <<< newWsServerImpl
-- newWebsocketServer :: ServerConfig -> Aff WSServer
-- newWebsocketServer = 

type RequestCallback = WSRequest -> Effect Unit

foreign import onRequest :: WSServer -> RequestCallback -> Effect Unit

type ConnectCallback = WSConnection -> Effect Unit

foreign import onConnect :: WSServer -> ConnectCallback -> Effect Unit

type CloseCallback =
  WSConnection -> CloseReason -> CloseDescription -> Effect Unit

foreign import onClose :: WSServer -> CloseCallback -> Effect Unit

foreign import shutdown :: WSServer -> Effect Unit