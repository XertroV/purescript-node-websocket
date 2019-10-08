module Node.Websocket.Aff.Client where

import Prelude

import Effect (Effect)
import Foreign (Foreign)
import Data.Nullable (Nullable, null)
import Node.HTTP as HTTP
import Node.Websocket.Aff.Types (ClientConfig, ErrorDescription, WSClient, WSConnection)

foreign import newWebsocketClient :: ClientConfig -> Effect WSClient

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

foreign import abort :: WSClient -> Effect Unit

type ConnectCallback = WSConnection -> Effect Unit

foreign import onConnect :: WSClient -> ConnectCallback -> Effect Unit

type ConnectFailedCallback = ErrorDescription -> Effect Unit

foreign import onConnectFailed :: WSClient -> ConnectFailedCallback -> Effect Unit

type HttpResponseCallback =  HTTP.Response -> WSClient -> Effect Unit

foreign import onHttpResponse :: WSClient -> HttpResponseCallback -> Effect Unit