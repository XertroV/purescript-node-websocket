module Node.Websocket.Aff.Request where

import Prelude

import Data.Nullable (Nullable)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff(..))
import Node.HTTP.Client (Request)
import Node.URL (URL)
import Node.Websocket.Aff.Internal (unimpl0, unimpl1)
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
foreign import acceptImpl :: WSRequest -> Nullable String -> Nullable String -> EffectFnAff WSConnection

accept_ :: WSRequest -> Nullable String -> Nullable String -> Aff WSConnection
accept_ req s1 s2 = unimpl0 (\_ -> acceptImpl req s1 s2) (pure unit)

foreign import reject :: WSRequest -> Nullable Int -> Nullable String -> Effect Unit

type RequestAcceptedCallback = WSConnection -> Effect Unit

foreign import onRequestAccepted :: WSRequest -> RequestAcceptedCallback -> Effect Unit

type RequestRejectedCallback = Effect Unit

foreign import onRequestRejected :: WSRequest -> RequestRejectedCallback -> Effect Unit