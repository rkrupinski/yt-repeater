module Components.Controls exposing (view, init, update, subscriptions, Msg, Model)

import Html exposing (..)
import QueryString as QS
import Navigation
import Material
import Material.Button as Button
import Material.Options as Options
import Slider.Core as Slider
import Slider.Helpers exposing (..)
import Utils exposing (defaultToEmpty, formatTime)
import Router


type Msg
    = SliderMsg Slider.Msg
    | ApplyRange
    | Mdl (Material.Msg Msg)


type alias Duration =
    Int


type alias VideoId =
    String


type Model
    = Model
        { videoId : VideoId
        , range : Slider.Range
        , slider : Slider.Model
        , mdl : Material.Model
        }


init : Duration -> Router.Params -> Model
init duration ({ v, start, end } as params) =
    let
        range : Slider.Range
        range =
            ( 0, toFloat duration )

        parseValue : Float -> Float
        parseValue =
            valueParser range

        initialValues : Slider.Range
        initialValues =
            ( Maybe.withDefault 0 start
                |> toFloat
                |> parseValue
            , Maybe.withDefault duration end
                |> toFloat
                |> parseValue
            )

        sliderConfig : Slider.Config
        sliderConfig =
            { defaultSliderConfig
                | step = Just <| stepParser range 1
                , values = Just initialValues
            }
    in
        Model
            { videoId = defaultToEmpty v
            , range = range
            , slider = Slider.init sliderConfig
            , mdl = Material.model
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model ({ videoId, range, slider } as model)) =
    case msg of
        SliderMsg sliderMsg ->
            let
                ( slider_, cmd ) =
                    Slider.update sliderMsg slider
            in
                Model
                    { model
                        | slider = slider_
                    }
                    ! [ Cmd.map SliderMsg cmd ]

        ApplyRange ->
            let
                formatValue : Float -> String
                formatValue =
                    valueFormatter range
                        >> round
                        >> toString

                ( start, end ) =
                    Slider.getValues slider

                newUrl : String
                newUrl =
                    QS.empty
                        |> QS.add "v" videoId
                        |> QS.add "start" (formatValue start)
                        |> QS.add "end" (formatValue end)
                        |> QS.render
            in
                Model model ! [ Navigation.modifyUrl newUrl ]

        Mdl mdlMsg ->
            let
                ( model_, cmd ) =
                    Material.update Mdl mdlMsg model
            in
                Model model_ ! [ cmd ]


view : Model -> Html Msg
view (Model { range, slider, mdl }) =
    let
        formatValue : Float -> Float
        formatValue =
            valueFormatter range

        ( start, end ) =
            Slider.getValues slider
    in
        p []
            [ Html.map SliderMsg <| Slider.view slider
            , span []
                [ text <| formatTime <| formatValue start
                , text " - "
                , text <| formatTime <| formatValue end
                ]
            , Button.render
                Mdl
                [ 0 ]
                mdl
                [ Button.raised
                , Options.onClick ApplyRange
                , Options.css "verticalAlign" "baseline"
                , Options.css "marginLeft" "1em"
                ]
                [ text "Apply" ]
            ]


subscriptions : Model -> Sub Msg
subscriptions (Model { slider }) =
    Sub.map SliderMsg <| Slider.subscriptions slider


defaultSliderConfig : Slider.Config
defaultSliderConfig =
    { size = Just 336
    , values = Nothing
    , step = Nothing
    }
