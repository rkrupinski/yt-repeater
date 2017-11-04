module Components.History
    exposing
        ( view
        , init
        , update
        , subscriptions
        , decodeEntries
        , Msg
        , Model
        )

import Html exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Material
import Material.Button as Button
import Material.Options as Options
import Ports exposing (readHistory, clearHistory)
import Router


type Msg
    = ReadEntries (Result String (List Entry))
    | ClearHistory
    | Mdl (Material.Msg Msg)


type Model
    = Model
        { baseUrl : Router.Url
        , entries : List Entry
        , mdl : Material.Model
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
        , mdl = Material.model
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

        ClearHistory ->
            Model model ! [ clearHistory Encode.null ]

        Mdl mdlMsg ->
            let
                ( model_, cmd ) =
                    Material.update Mdl mdlMsg model
            in
                Model model_ ! [ cmd ]


view : Model -> Html Msg
view (Model { entries, mdl }) =
    case List.length entries of
        0 ->
            p [] [ text "History is empty" ]

        _ ->
            div []
                [ ul [] <| List.map renderEntry entries
                , Button.render
                    Mdl
                    [ 0 ]
                    mdl
                    [ Button.raised
                    , Options.onClick ClearHistory
                    ]
                    [ text "Apply" ]
                ]


renderEntry : Entry -> Html Msg
renderEntry { title } =
    li [] [ text title ]


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
