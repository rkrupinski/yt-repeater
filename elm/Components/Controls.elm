module Components.Controls exposing (view, init, Msg, Model)

import Html exposing (..)
import Slider.Core as Slider
import Slider.Helpers exposing (valueFormatter, valueParser, stepParser)


type Msg
    = Noop


type Model
    = Model {}


init : Model
init =
    Model {}


view : Model -> Html Msg
view _ =
    p [] [ text "Controls" ]


defaultSliderConfig : Slider.Config
defaultSliderConfig =
    { size = Just 400
    , values = Nothing
    , step = Nothing
    }
