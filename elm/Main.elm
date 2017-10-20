module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Slider.Core as Slider
import String exposing (..)
import Slider.Helpers exposing (valueFormatter, stepParser)
import Css exposing (asPairs)
import Assets
import Styles


styles : List Css.Style -> Attribute msg
styles =
    asPairs >> Html.Attributes.style


type Msg
    = YTApiReady
    | InputVideoId String
    | SubmitVideoId
    | VideoMeta Float
    | SliderMsg Slider.Msg
    | ApplyRange


type alias Attrs =
    { videoId : String
    , range : String
    }


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { apiReady : Bool
    , videoId : Maybe String
    , videoDuration : Maybe Float
    , slider : Maybe Slider.Model
    , attrs : Attrs
    }


defaultSliderConfig : Slider.Config
defaultSliderConfig =
    { size = Just 400
    , values = Nothing
    , step = Nothing
    }


init : ( Model, Cmd Msg )
init =
    Model False Nothing Nothing Nothing (Attrs "" "") ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ videoId, videoDuration, slider, attrs } as model) =
    case msg of
        YTApiReady ->
            { model | apiReady = True } ! []

        InputVideoId value ->
            { model | videoId = value |> String.trim |> Just } ! []

        SubmitVideoId ->
            let
                newAttrs : Attrs
                newAttrs =
                    case videoId of
                        Just videoId_ ->
                            { attrs | videoId = videoId_ }

                        _ ->
                            attrs
            in
                { model | attrs = newAttrs } ! []

        VideoMeta duration ->
            let
                sliderConfig : Slider.Config
                sliderConfig =
                    { defaultSliderConfig | step = Just <| stepParser ( 0, duration ) 1 }

                slider : Slider.Model
                slider =
                    Slider.init sliderConfig

                newAttrs : Attrs
                newAttrs =
                    { attrs | range = formatRange slider duration }
            in
                { model
                    | videoDuration = Just duration
                    , slider = Just slider
                    , attrs = newAttrs
                }
                    ! []

        SliderMsg sliderMsg ->
            case slider of
                Just slider_ ->
                    let
                        ( newSlider, cmd ) =
                            Slider.update sliderMsg slider_
                    in
                        { model | slider = Just newSlider } ! [ Cmd.map SliderMsg cmd ]

                _ ->
                    model ! []

        ApplyRange ->
            case ( slider, videoDuration ) of
                ( Just slider_, Just duration ) ->
                    let
                        newAttrs : Attrs
                        newAttrs =
                            { attrs | range = formatRange slider_ duration }
                    in
                        { model | attrs = newAttrs } ! []

                _ ->
                    model ! []


view : Model -> Html Msg
view model =
    div [ styles Styles.container ]
        [ renderHeader
        , renderForm model
        , renderControls model
        , renderPlayer model
        , renderFooter
        ]


renderHeader : Html never
renderHeader =
    let
        logoUrl : String
        logoUrl =
            Assets.path Assets.logo
    in
        header []
            [ h1
                [ styles Styles.heading ]
                [ img
                    [ src logoUrl
                    , alt "YouTube"
                    , styles Styles.logo
                    ]
                    []
                , text " "
                , text "repeater"
                ]
            ]


renderForm : Model -> Html Msg
renderForm { apiReady, videoId } =
    if apiReady then
        let
            fieldValue : String
            fieldValue =
                Maybe.withDefault "" videoId
        in
            Html.form
                [ onSubmit SubmitVideoId
                , styles Styles.section
                ]
                [ label
                    [ for "videoId"
                    , styles Styles.formElement
                    ]
                    [ text "Video id:" ]
                , input
                    [ id "videoId"
                    , name "videoId"
                    , value fieldValue
                    , onInput InputVideoId
                    , styles Styles.formElement
                    ]
                    []
                , button
                    [ styles Styles.formElement
                    , type_ "submit"
                    ]
                    [ text "Load" ]
                ]
    else
        p [] [ text "Loading..." ]


renderControls : Model -> Html Msg
renderControls { videoDuration, slider } =
    case ( videoDuration, slider ) of
        ( Just duration, Just slider_ ) ->
            let
                ( start, end ) =
                    Slider.getValues slider_

                formatValue : Float -> Float
                formatValue =
                    valueFormatter ( 0, duration )
            in
                div [ styles Styles.section ]
                    [ Html.map SliderMsg <| Slider.view slider_
                    , p []
                        [ text <| formatTime <| formatValue start
                        , text " - "
                        , text <| formatTime <| formatValue end
                        ]
                    , button
                        [ onClick ApplyRange
                        , styles Styles.formElement
                        ]
                        [ text "Apply range" ]
                    ]

        _ ->
            text ""


renderPlayer : Model -> Html Msg
renderPlayer { videoDuration, slider, attrs } =
    let
        decodeApiReady : Decode.Decoder Msg
        decodeApiReady =
            Decode.succeed YTApiReady

        decodeVideoMeta : Decode.Decoder Msg
        decodeVideoMeta =
            Decode.map VideoMeta <| Decode.field "detail" Decode.float

        { videoId, range } =
            attrs
    in
        div [ styles Styles.section ]
            [ node "youtube-embed"
                [ on "yt-api-ready" decodeApiReady
                , on "video-meta" decodeVideoMeta
                , attribute "video-id" videoId
                , attribute "range" range
                ]
                []
            ]


renderFooter : Html never
renderFooter =
    footer []
        [ a
            [ href "https://github.com/rkrupinski/yt-repeater" ]
            [ text "View source" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions { slider } =
    case slider of
        Just slider_ ->
            Sub.map SliderMsg <| Slider.subscriptions slider_

        _ ->
            Sub.none


formatRange : Slider.Model -> Float -> String
formatRange slider duration =
    let
        values : Slider.Values
        values =
            Slider.getValues slider

        formatValue : Float -> Float
        formatValue =
            valueFormatter ( 0, duration )

        ( start, end ) =
            values
                |> Tuple.mapFirst formatValue
                |> Tuple.mapSecond formatValue
    in
        (toString start) ++ "-" ++ (toString end)


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
