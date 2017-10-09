module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Slider.Core as Slider
import String exposing (..)
import Slider.Helpers exposing (valueParser, valueFormatter, stepParser)
import Ports exposing (..)
import Css exposing (asPairs)
import Assets
import Styles


styles : List Css.Style -> Attribute msg
styles =
    asPairs >> Html.Attributes.style


type Msg
    = ApiReady Bool
    | InputVideoId String
    | SubmitVideoId
    | VideoMeta (Result String Meta)
    | SliderMsg Slider.Msg
    | ApplyRange


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
    { size = Just 400
    , values = Nothing
    , step = Nothing
    }


init : ( Model, Cmd Msg )
init =
    Model False Nothing Nothing Nothing ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ video, range, videoId } as model) =
    case msg of
        ApiReady ready ->
            { model | apiReady = ready } ! []

        InputVideoId current ->
            { model | videoId = Just <| String.trim current } ! []

        SubmitVideoId ->
            model ! [ Ports.videoId <| Maybe.withDefault "" videoId ]

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
                    ! [ Ports.range <| encodeRange start end ]

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

        ApplyRange ->
            case (video) of
                Just { start, end } ->
                    model ! [ Ports.range <| encodeRange start end ]

                _ ->
                    model ! []


encodeRange : Float -> Float -> Encode.Value
encodeRange start end =
    Encode.object
        [ ( "start", Encode.float start )
        , ( "end", Encode.float end )
        ]


view : Model -> Html Msg
view model =
    let
        logoUrl : String
        logoUrl =
            Assets.path Assets.logo
    in
        div [ styles Styles.container ]
            [ h1 [ styles Styles.heading ]
                [ img
                    [ src logoUrl
                    , alt "YouTube"
                    , styles Styles.logo
                    ]
                    []
                , text " "
                , text "repeater"
                ]
            , renderForm model
            , renderControls model
            , renderPlayer
            , a [ href "https://github.com/rkrupinski/yt-repeater" ] [ text "View source" ]
            ]


renderForm : Model -> Html Msg
renderForm { apiReady } =
    if apiReady then
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


formatTime : Float -> String
formatTime seconds =
    let
        minutes : String
        minutes =
            seconds
                |> round
                |> flip (//) 60
                |> toString
                |> padLeft 2 '0'

        seconds_ : String
        seconds_ =
            seconds
                |> round
                |> flip (%) 60
                |> toString
                |> padLeft 2 '0'
    in
        minutes ++ ":" ++ seconds_


renderControls : Model -> Html Msg
renderControls { range, video } =
    case ( range, video ) of
        ( Just currentRange, Just { start, end } ) ->
            div [ styles Styles.section ]
                [ Html.map SliderMsg <| Slider.view currentRange
                , p []
                    [ text <| formatTime start
                    , text " - "
                    , text <| formatTime end
                    , text " "
                    ]
                , button
                    [ onClick ApplyRange
                    , styles Styles.formElement
                    ]
                    [ text "Apply range" ]
                ]

        _ ->
            text ""


renderPlayer : Html Msg
renderPlayer =
    div [ styles Styles.section ]
        [ div [ id "player" ] []
        ]


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
