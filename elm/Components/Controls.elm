module Components.Controls exposing (view, init, Msg, Model)

import Html exposing (..)


type Msg
    = Noop


type Model
    = Model {}


type alias Params =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


init : Params -> Model
init params =
    Model
        {}


view : Model -> Html Msg
view _ =
    p [] [ text "Controls" ]
