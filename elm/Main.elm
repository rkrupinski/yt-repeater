module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Ports exposing (..)
import Assets


type Msg
    = ApiReady Bool
    | InputVideoId String
    | SubmitVideoId
    | VideoMeta (Result String Meta)


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
    }


type alias Meta =
    { duration : Float
    }


type alias Video =
    { duration : Float
    , start : Float
    , end : Float
    }


init : ( Model, Cmd Msg )
init =
    Model False Nothing Nothing ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ApiReady ready ->
            { model | apiReady = ready } ! []

        InputVideoId current ->
            { model | videoId = Just <| String.trim current } ! []

        SubmitVideoId ->
            model ! [ Ports.videoId <| Maybe.withDefault "" model.videoId ]

        VideoMeta (Ok { duration }) ->
            { model | video = Just <| Video duration 0 duration } ! []

        VideoMeta (Result.Err _) ->
            model ! []


view : Model -> Html Msg
view { apiReady, video } =
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
            , renderForm apiReady
            , renderControls video
            ]


renderForm : Bool -> Html Msg
renderForm ready =
    if ready then
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


renderControls : Maybe Video -> Html Msg
renderControls video =
    case video of
        Just { duration, start, end } ->
            div []
                [ pre []
                    [ text <| toString duration
                    , text ", "
                    , text <| toString start
                    , text ", "
                    , text <| toString end
                    ]
                , button [] [ text "Apply" ]
                ]

        _ ->
            text ""


decodeVideoMeta : Decode.Value -> Result String Meta
decodeVideoMeta =
    Decode.decodeValue <| Decode.map Meta <| Decode.field "duration" Decode.float


subscriptions : Model -> Sub Msg
subscriptions { apiReady } =
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
    in
        Sub.batch
            [ apiSub
            , metaSub
            ]
