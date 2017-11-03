module Utils exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import String exposing (padLeft, join)
import Json.Encode as Encode
import Json.Decode as Decode
import Css exposing (asPairs)


styles : List Css.Style -> Attribute msg
styles =
    asPairs >> style


defaultToEmpty : Maybe String -> String
defaultToEmpty =
    Maybe.withDefault ""


formatTime : Float -> String
formatTime seconds =
    let
        seconds_ : Int
        seconds_ =
            round seconds

        hh : Int
        hh =
            seconds_ // 3600

        mm : Int
        mm =
            seconds_
                |> flip (%) 3600
                |> flip (//) 60

        ss : Int
        ss =
            seconds_
                |> flip (%) 3600
                |> flip (%) 60
    in
        [ hh, mm, ss ]
            |> List.map toString
            |> List.map (padLeft 2 '0')
            |> join ":"


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder maybe =
    Maybe.map encoder maybe |> Maybe.withDefault Encode.null
