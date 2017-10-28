module Utils exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Css exposing (asPairs)


styles : List Css.Style -> Attribute msg
styles =
    asPairs >> style


defaultToEmpty : Maybe String -> String
defaultToEmpty =
    Maybe.withDefault ""
