module Node.Websocket.Aff.Server where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Node.Websocket.Aff.Internal (unimpl1, unimpl0, unimpl3)
import Node.Websocket.Aff.Types (CloseDescription, CloseReason, ServerConfig, WSConnection, WSRequest, WSServer)

foreign import newWebsocketServer :: ServerConfig -> Effect WSServer

foreign import newWebsocketServerImpl :: ServerConfig -> EffectFnAff WSServer

newWebsocketServer_ :: ServerConfig -> Aff WSServer
newWebsocketServer_ = fromEffectFnAff <<< newWebsocketServerImpl
-- newWebsocketServer :: ServerConfig -> Aff WSServer
-- newWebsocketServer = 

type RequestCallback = WSRequest -> Effect Unit
type RequestCallback' = WSRequest -> Aff Unit

foreign import onRequest :: WSServer -> RequestCallback -> Effect Unit

foreign import onRequestImpl :: WSServer -> RequestCallback -> EffectFnAff Unit

-- onRequest_ :: WSServer -> RequestCallback' -> Aff Unit
onRequest_ svr cb = unimpl1 (onRequestImpl svr) cb

type ConnectCallback = WSConnection -> Effect Unit
type ConnectCallback' = WSConnection -> Aff Unit

foreign import onConnect :: WSServer -> ConnectCallback -> Effect Unit

type CloseCallback =
  WSConnection -> CloseReason -> CloseDescription -> Effect Unit
foreign import onClose :: WSServer -> CloseCallback -> Effect Unit
foreign import onCloseImpl :: WSServer -> CloseCallback -> EffectFnAff Unit

onClose_ svr cb = unimpl3 (onCloseImpl svr) cb

-- onClose_ :: WSServer -> CloseCallback' -> Aff Unit
-- onClose_ svr cb = unimpl (onCloseImpl svr) cb

foreign import shutdown :: WSServer -> Effect Unit
foreign import shutdownImpl :: WSServer -> EffectFnAff Unit

shutdown_ svr = unimpl0 (\_ -> shutdownImpl svr) (pure unit)