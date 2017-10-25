module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (padLeft, join)
import Json.Decode as Decode
import Css exposing (asPairs)
import UrlParser as Url exposing ((<?>), parsePath, stringParam, intParam, top)
import Navigation
import QueryString as QS
import Slider.Core as Slider
import Slider.Helpers exposing (valueFormatter, valueParser, stepParser)
import Assets
import Styles


type Msg
    = YTApiReady
    | InputVideoId String
    | SubmitVideoId
    | VideoMeta Duration
    | SliderMsg Slider.Msg
    | ApplyRange
    | UrlChange Navigation.Location


type alias Duration =
    Int


type alias QueryParams =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


type alias Attrs =
    { v : String
    , start : String
    , end : String
    }


type alias Model =
    { apiReady : Bool
    , videoId : Maybe String
    , videoDuration : Maybe Duration
    , slider : Maybe Slider.Model
    , queryParams : QueryParams
    , attrs : Attrs
    }


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        ({ v } as queryParams) =
            extractQueryParams location

        attrs : Attrs
        attrs =
            buildAttrs queryParams
    in
        Model False v Nothing Nothing queryParams attrs ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ videoId, videoDuration, slider, queryParams, attrs } as model) =
    case msg of
        YTApiReady ->
            { model | apiReady = True } ! []

        InputVideoId value ->
            { model
                | videoId =
                    value
                        |> String.trim
                        |> Just
            }
                ! []

        SubmitVideoId ->
            let
                newUrl : String
                newUrl =
                    QS.empty
                        |> QS.add "v" (defaultToEmpty videoId)
                        |> QS.render
            in
                model ! [ Navigation.modifyUrl <| Debug.log "new url" newUrl ]

        VideoMeta duration ->
            let
                { v, start, end } =
                    queryParams

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

                slider : Slider.Model
                slider =
                    Slider.init sliderConfig
            in
                { model
                    | videoDuration = Just duration
                    , slider = Just slider
                }
                    ! []

        SliderMsg sliderMsg ->
            case slider of
                Just slider_ ->
                    let
                        ( newSlider, cmd ) =
                            Slider.update sliderMsg slider_
                    in
                        { model
                            | slider = Just newSlider
                        }
                            ! [ Cmd.map SliderMsg cmd ]

                _ ->
                    model ! []

        ApplyRange ->
            case ( slider, videoDuration ) of
                ( Just slider_, Just duration ) ->
                    let
                        { v } =
                            queryParams

                        formatValue : Float -> String
                        formatValue =
                            valueFormatter ( 0, toFloat duration )
                                >> round
                                >> toString

                        ( start, end ) =
                            Slider.getValues slider_

                        newUrl : String
                        newUrl =
                            QS.empty
                                |> QS.add "v" (defaultToEmpty v)
                                |> QS.add "start" (formatValue start)
                                |> QS.add "end" (formatValue end)
                                |> QS.render
                    in
                        model ! [ Navigation.modifyUrl newUrl ]

                _ ->
                    model ! []

        UrlChange location ->
            let
                ({ v } as queryParams) =
                    extractQueryParams location
            in
                { model
                    | videoId = v
                    , queryParams = queryParams
                    , attrs = buildAttrs queryParams
                }
                    ! []


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
                , value <| defaultToEmpty videoId
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
                    valueFormatter ( 0, toFloat duration )
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
            Decode.map VideoMeta <| Decode.field "detail" Decode.int

        { v, start, end } =
            attrs

        extraAttrs : List (Attribute Msg)
        extraAttrs =
            case videoDuration of
                Just duration ->
                    [ attribute "start" start
                    , attribute "end" end
                    ]

                _ ->
                    []
    in
        div [ styles Styles.section ]
            [ node "youtube-embed"
                ([ on "yt-api-ready" decodeApiReady
                 , on "video-meta" decodeVideoMeta
                 , attribute "v" v
                 ]
                    ++ extraAttrs
                )
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


defaultSliderConfig : Slider.Config
defaultSliderConfig =
    { size = Just 400
    , values = Nothing
    , step = Nothing
    }


styles : List Css.Style -> Attribute msg
styles =
    asPairs >> Html.Attributes.style


defaultToEmpty : Maybe String -> String
defaultToEmpty =
    Maybe.withDefault ""


buildAttrs : QueryParams -> Attrs
buildAttrs { v, start, end } =
    Attrs
        (defaultToEmpty v)
        (start |> Maybe.map toString |> defaultToEmpty)
        (end |> Maybe.map toString |> defaultToEmpty)


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


parseQueryString : Navigation.Location -> Maybe QueryParams
parseQueryString location =
    let
        queryParser =
            top <?> stringParam "v" <?> intParam "start" <?> intParam "end"
    in
        parsePath (Url.map QueryParams queryParser) location


extractQueryParams : Navigation.Location -> QueryParams
extractQueryParams location =
    let
        defaultParams : QueryParams
        defaultParams =
            QueryParams Nothing Nothing Nothing
    in
        Maybe.withDefault defaultParams <| parseQueryString location
