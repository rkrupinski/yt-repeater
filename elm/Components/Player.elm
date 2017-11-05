module Components.Player
    exposing
        ( view
        , init
        , update
        , getApiReady
        , getVideoDuration
        , Msg(SetParams)
        , Model
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Utils exposing (styles, defaultToEmpty, encodeMaybe)
import Ports exposing (amendHistory)
import Router
import Styles


type Msg
    = YTApiReady
    | VideoMeta Meta
    | VideoPlaying Playing
    | SetParams Router.Params


type alias Duration =
    Int


type alias Meta =
    { duration : Duration
    }


type alias Playing =
    { videoId : String
    , title : String
    , startSeconds : Maybe Int
    , endSeconds : Maybe Int
    }


type alias Attrs =
    { v : String
    , start : String
    , end : String
    }


type Model
    = Model
        { apiReady : Bool
        , videoDuration : Maybe Duration
        , attrs : Attrs
        }


init : Router.Params -> Model
init params =
    Model
        { apiReady = False
        , videoDuration = Nothing
        , attrs = buildAttrs params
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        YTApiReady ->
            Model { model | apiReady = True } ! []

        VideoMeta ({ duration } as meta) ->
            Model { model | videoDuration = Just duration } ! []

        VideoPlaying playing ->
            Model model ! [ amendHistory <| encodeEntry playing ]

        SetParams params ->
            Model { model | attrs = buildAttrs params } ! []


getApiReady : Model -> Bool
getApiReady (Model { apiReady }) =
    apiReady


getVideoDuration : Model -> Maybe Duration
getVideoDuration (Model { videoDuration }) =
    videoDuration


view : Model -> Html Msg
view (Model { attrs }) =
    let
        { v, start, end } =
            attrs
    in
        p [ styles Styles.player ]
            [ node "youtube-embed"
                [ on "yt-api-ready" decodeApiReady
                , on "video-meta" decodeVideoMeta
                , on "video-playing" decodeVideoPlaying
                , attribute "v" v
                , attribute "start" start
                , attribute "end" end
                ]
                []
            ]


decodeApiReady : Decode.Decoder Msg
decodeApiReady =
    Decode.succeed YTApiReady


decodeVideoMeta : Decode.Decoder Msg
decodeVideoMeta =
    Decode.map VideoMeta <|
        Decode.map Meta
            (Decode.at [ "detail", "duration" ] Decode.int)


decodeVideoPlaying : Decode.Decoder Msg
decodeVideoPlaying =
    Decode.map VideoPlaying <|
        Decode.map4 Playing
            (Decode.at [ "detail", "videoId" ] Decode.string)
            (Decode.at [ "detail", "title" ] Decode.string)
            (Decode.maybe <| Decode.at [ "detail", "startSeconds" ] Decode.int)
            (Decode.maybe <| Decode.at [ "detail", "endSeconds" ] Decode.int)


encodeEntry : Playing -> Encode.Value
encodeEntry { videoId, title, startSeconds, endSeconds } =
    Encode.object
        [ ( "videoId", Encode.string videoId )
        , ( "title", Encode.string title )
        , ( "startSeconds", encodeMaybe Encode.int startSeconds )
        , ( "endSeconds", encodeMaybe Encode.int endSeconds )
        ]


buildAttrs : Router.Params -> Attrs
buildAttrs { v, start, end } =
    Attrs
        (defaultToEmpty v)
        (start |> Maybe.map toString |> defaultToEmpty)
        (end |> Maybe.map toString |> defaultToEmpty)
