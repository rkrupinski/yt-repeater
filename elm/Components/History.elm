module Components.History
    exposing
        ( view
        , init
        , update
        , subscriptions
        , Msg
        , Model
        )

import Html exposing (..)
import Json.Decode as Decode
import Ports exposing (readHistory)
import Router


type Msg
    = ReadEntries (Result String (List Entry))


type Model
    = Model
        { baseUrl : Router.Url
        , entries : List Entry
        }


type alias Entry =
    { videoId : String
    , title : String
    , startSeconds : Maybe Int
    , endSeconds : Maybe Int
    }


init : Router.Url -> Model
init baseUrl =
    Model
        { baseUrl = baseUrl
        , entries = []
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        ReadEntries (Ok entries) ->
            Model
                { model
                    | entries = entries
                }
                ! []

        ReadEntries (Result.Err _) ->
            Model model ! []


view : Model -> Html Msg
view (Model { entries }) =
    ul []
        (List.map
            (\entry -> li [] [ text entry.title ])
            entries
        )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ readHistory <| decodeEntries >> ReadEntries
        ]


decodeEntries : Decode.Value -> Result String (List Entry)
decodeEntries =
    Decode.decodeValue <|
        Decode.list <|
            Decode.map4 Entry
                (Decode.field "videoId" Decode.string)
                (Decode.field "title" Decode.string)
                (Decode.maybe <| Decode.field "startSeconds" Decode.int)
                (Decode.maybe <| Decode.field "endSeconds" Decode.int)
