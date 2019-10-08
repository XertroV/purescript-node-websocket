module Node.Websocket.Aff.Internal where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)

unimpl3 :: forall r. (_ -> EffectFnAff r) -> (_ -> _ -> _ -> Aff Unit) -> Aff r
unimpl3 h cb = fromEffectFnAff $ h (\a b c -> launchAff_ $ cb a b c)

unimpl2 :: forall a. (_ -> EffectFnAff a) -> (_ -> _ -> Aff Unit) -> Aff a
unimpl2 h cb = fromEffectFnAff $ h (\a b -> launchAff_ $ cb a b)

unimpl1 :: forall a. (_ -> EffectFnAff a) -> (_ -> Aff Unit) -> Aff a
-- unimpl1 handlerImpl cb = fromEffectFnAff $ handlerImpl (launchAff_ <<< cb)
unimpl1 h cb = fromEffectFnAff $ h (\a -> launchAff_ $ cb a)

unimpl0 :: forall a. (_ -> EffectFnAff a) -> (Aff Unit) -> Aff a
unimpl0 h cb = fromEffectFnAff $ h (launchAff_ cb)
