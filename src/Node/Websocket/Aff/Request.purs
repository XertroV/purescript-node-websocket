module Node.Websocket.Aff.Request where

import Prelude

import Effect (Effect)
import Data.Nullable (Nullable)
import Node.HTTP.Client (Request)
import Node.URL (URL)
import Node.Websocket.Aff.Types (WSConnection, WSRequest)

foreign import httpRequest :: WSRequest -> Request

foreign import host :: WSRequest -> String

foreign import resource :: WSRequest -> String

foreign import resourceURL :: WSRequest -> URL

foreign import remoteAddress :: WSRequest -> String

foreign import webSocketVersion :: WSRequest -> Number

foreign import origin :: WSRequest -> Nullable String

foreign import requestedProtocols :: WSRequest -> Array String

foreign import accept :: WSRequest -> Nullable String -> Nullable String -> Effect WSConnection

foreign import reject :: WSRequest -> Nullable Int -> Nullable String -> Effect Unit

type RequestAcceptedCallback = WSConnection -> Effect Unit

foreign import onRequestAccepted :: WSRequest -> RequestAcceptedCallback -> Effect Unit

type RequestRejectedCallback = Effect Unit

foreign import onRequestRejected :: WSRequest -> RequestRejectedCallback -> Effect Unit