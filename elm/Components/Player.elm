module Components.Player exposing (view, init, update, getApiReady, Msg(SetParams), Model)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Utils exposing (styles, defaultToEmpty)
import Styles


type Msg
    = YTApiReady
    | VideoMeta Duration
    | SetParams Params


type alias Duration =
    Int


type alias Attrs =
    { v : String
    , start : String
    , end : String
    }


type alias Params =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


type Model
    = Model
        { apiReady : Bool
        , videoDuration : Maybe Duration
        , attrs : Attrs
        }


init : Params -> Model
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

        VideoMeta duration ->
            Model { model | videoDuration = Just duration } ! []

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
        div [ styles Styles.section ]
            [ node "youtube-embed"
                [ on "yt-api-ready" decodeApiReady
                , on "video-meta" decodeVideoMeta
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
    Decode.map VideoMeta <| Decode.field "detail" Decode.int


buildAttrs : Params -> Attrs
buildAttrs { v, start, end } =
    Attrs
        (defaultToEmpty v)
        (start |> Maybe.map toString |> defaultToEmpty)
        (end |> Maybe.map toString |> defaultToEmpty)
