module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Slider.Core as Slider
import Slider.Helpers exposing (valueParser, valueFormatter, stepParser)
import Ports exposing (..)
import Assets


type Msg
    = ApiReady Bool
    | InputVideoId String
    | SubmitVideoId
    | VideoMeta (Result String Meta)
    | SliderMsg Slider.Msg


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
    , video : Maybe Video
    , range : Maybe Slider.Model
    }


type alias Meta =
    { duration : Float
    }


type alias Video =
    { duration : Float
    , start : Float
    , end : Float
    }


defaultRangeConfig : Slider.Config
defaultRangeConfig =
    { size = Just 640
    , values = Just ( 0, 1 )
    , step = Just 1
    }


init : ( Model, Cmd Msg )
init =
    Model False Nothing Nothing Nothing ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ video, range } as model) =
    case msg of
        ApiReady ready ->
            { model | apiReady = ready } ! []

        InputVideoId current ->
            { model | videoId = Just <| String.trim current } ! []

        SubmitVideoId ->
            model ! [ Ports.videoId <| Maybe.withDefault "" model.videoId ]

        VideoMeta (Ok { duration }) ->
            let
                newVideo : Video
                newVideo =
                    Video duration 0 duration

                { start, end } =
                    newVideo

                sliderRange : Slider.Range
                sliderRange =
                    ( 0, duration )

                parseValue : Float -> Float
                parseValue =
                    valueParser sliderRange

                parseStep : Float -> Float
                parseStep =
                    stepParser sliderRange

                rangeConfig : Slider.Config
                rangeConfig =
                    { defaultRangeConfig
                        | values = Just ( parseValue start, parseValue end )
                        , step = Just <| parseStep 1
                    }
            in
                { model
                    | video = Just newVideo
                    , range = Just <| Slider.init rangeConfig
                }
                    ! []

        VideoMeta (Result.Err _) ->
            model ! []

        SliderMsg sliderMsg ->
            let
                ( newRange, cmd ) =
                    case range of
                        Just currentRange ->
                            Slider.update sliderMsg currentRange

                        _ ->
                            Slider.init defaultRangeConfig ! []

                ( from, to ) =
                    Slider.getValues newRange

                newVideo : Video
                newVideo =
                    case video of
                        Just ({ duration } as currentVideo) ->
                            let
                                sliderRange : Slider.Range
                                sliderRange =
                                    ( 0, duration )

                                formatValue : Float -> Float
                                formatValue =
                                    valueFormatter sliderRange
                            in
                                { currentVideo
                                    | start = formatValue from
                                    , end = formatValue to
                                }

                        _ ->
                            Video 0 0 0
            in
                { model
                    | range = Just newRange
                    , video = Just newVideo
                }
                    ! [ Cmd.map SliderMsg cmd ]


view : Model -> Html Msg
view model =
    let
        logoUrl : String
        logoUrl =
            Assets.path Assets.logo
    in
        div []
            [ h1 []
                [ img
                    [ src logoUrl
                    , alt "YouTube"
                    , width 100
                    ]
                    []
                , text " "
                , text "repeater"
                ]
            , renderForm model
            , renderControls model
            ]


renderForm : Model -> Html Msg
renderForm { apiReady } =
    if apiReady then
        Html.form [ onSubmit SubmitVideoId ]
            [ label [ for "videoId" ] [ text "Video id:" ]
            , input
                [ id "videoId"
                , name "videoId"
                , onInput InputVideoId
                ]
                []
            , input [ type_ "submit" ] []
            ]
    else
        p [] [ text "Loading..." ]


renderControls : Model -> Html Msg
renderControls { range } =
    case range of
        Just currentRange ->
            div []
                [ Html.map SliderMsg <| Slider.view currentRange
                , button [] [ text "Apply" ]
                ]

        _ ->
            text ""


decodeVideoMeta : Decode.Value -> Result String Meta
decodeVideoMeta =
    Decode.decodeValue <|
        Decode.map Meta <|
            Decode.field "duration" Decode.float


subscriptions : Model -> Sub Msg
subscriptions { apiReady, video, range } =
    let
        apiSub : Sub Msg
        apiSub =
            if (not apiReady) then
                Ports.apiReady ApiReady
            else
                Sub.none

        metaSub : Sub Msg
        metaSub =
            if apiReady then
                Ports.videoMeta (decodeVideoMeta >> VideoMeta)
            else
                Sub.none

        rangeSub : Sub Msg
        rangeSub =
            case ( video, range ) of
                ( Just _, Just currentRange ) ->
                    Sub.map SliderMsg <| Slider.subscriptions currentRange

                _ ->
                    Sub.none
    in
        Sub.batch
            [ apiSub
            , metaSub
            , rangeSub
            ]
