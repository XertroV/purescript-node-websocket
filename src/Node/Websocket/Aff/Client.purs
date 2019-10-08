module Node.Websocket.Aff.Client where

import Prelude

import Data.Nullable (Nullable, null)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)
import Node.HTTP as HTTP
import Node.Websocket.Aff.Internal (unimpl1)
import Node.Websocket.Aff.Types (ClientConfig, ErrorDescription, WSClient, WSConnection)

foreign import newWebsocketClient :: ClientConfig -> Effect WSClient
foreign import newWebsocketClientImpl :: ClientConfig -> EffectFnAff WSClient
newWebsocketClient_ :: ClientConfig -> Aff WSClient
newWebsocketClient_ config = fromEffectFnAff $ newWebsocketClientImpl config

type ConnectOptions =
    { protocols :: Nullable (Array String)  -- list of multiple subprotocols supported by the client
    , origin :: Nullable String  -- optional, used by browsers (I think?)
    , headers :: Nullable Foreign  -- object of headers to send with request
    , options :: Nullable Foreign  -- object passed to node's http(s).request
    }

type URLString = String

defaultConnectOptions :: ConnectOptions
defaultConnectOptions = {protocols: null, origin: null, headers: null, options: null}

foreign import connect :: WSClient -> URLString -> ConnectOptions -> Effect Unit
foreign import connectImpl :: WSClient -> URLString -> ConnectOptions -> EffectFnAff Unit
connect_ :: WSClient -> URLString -> ConnectOptions -> Aff Unit
connect_ client url opts = fromEffectFnAff $ connectImpl client url opts

foreign import abort :: WSClient -> Effect Unit

type ConnectCallback = WSConnection -> Effect Unit
type ConnectCallback' = WSConnection -> Aff Unit

foreign import onConnect :: WSClient -> ConnectCallback -> Effect Unit
foreign import onConnectImpl :: WSClient -> ConnectCallback -> EffectFnAff Unit
onConnect_ :: WSClient -> ConnectCallback' -> Aff Unit
onConnect_ client cb = unimpl1 (onConnectImpl client) cb

type ConnectFailedCallback = ErrorDescription -> Effect Unit

foreign import onConnectFailed :: WSClient -> ConnectFailedCallback -> Effect Unit

type HttpResponseCallback =  HTTP.Response -> WSClient -> Effect Unit

foreign import onHttpResponse :: WSClient -> HttpResponseCallback -> Effect Unit