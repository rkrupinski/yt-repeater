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
import Html.Attributes exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import QueryString as QS
import Material
import Material.Button as Button
import Material.Typography as Typography
import Material.Options as Options
import Material.Icon as Icon
import Utils exposing (formatTime, truncateText, styles)
import Ports exposing (readHistory, clearHistory)
import Styles


type Msg
    = ReadEntries (Result String (List Entry))
    | ClearHistory
    | Mdl (Material.Msg Msg)


type Model
    = Model
        { entries : List Entry
        , mdl : Material.Model
        }


type alias Entry =
    { videoId : String
    , title : String
    , startSeconds : Maybe Int
    , endSeconds : Maybe Int
    }


init : Model
init =
    Model
        { entries = []
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
    let
        recentlyPlayed : Html Msg
        recentlyPlayed =
            case List.length entries of
                0 ->
                    p [] [ text "There is nothing here yet." ]

                _ ->
                    ul
                        [ styles Styles.history
                        ]
                    <|
                        List.map renderEntry entries
    in
        div []
            [ Options.styled h3
                [ Typography.title ]
                [ text "Recently played:"
                ]
            , recentlyPlayed
            , p []
                [ Button.render
                    Mdl
                    [ 0 ]
                    mdl
                    [ Options.onClick ClearHistory
                    , Options.disabled <| List.length entries == 0
                    , Button.raised
                    ]
                    [ text "Clear history"
                    ]
                ]
            ]


addMaybe : String -> Maybe a -> QS.QueryString -> QS.QueryString
addMaybe name value =
    case value of
        Just value_ ->
            QS.add name <| toString value_

        _ ->
            identity


permalink : Entry -> String
permalink { videoId, startSeconds, endSeconds } =
    QS.empty
        |> QS.add "v" videoId
        |> addMaybe "start" startSeconds
        |> addMaybe "end" endSeconds
        |> QS.render


thumbUrl : String -> String
thumbUrl videoId =
    "https://img.youtube.com/vi/" ++ videoId ++ "/2.jpg"


renderRange : Maybe Int -> Maybe Int -> Html never
renderRange start end =
    case ( start, end ) of
        ( Just start_, Just end_ ) ->
            let
                format : Int -> String
                format =
                    toFloat >> formatTime
            in
                span [ styles Styles.historyRange ]
                    [ Icon.view "schedule"
                        [ Icon.size18
                        , Options.css "verticalAlign" "middle"
                        , Options.css "margin" "-2px 3px -1px -3px"
                        ]
                    , text <| format start_
                    , text " - "
                    , text <| format end_
                    ]

        _ ->
            text ""


renderEntry : Entry -> Html Msg
renderEntry ({ videoId, title, startSeconds, endSeconds } as entry) =
    li [ styles Styles.historyEntry ]
        [ a
            [ href <| permalink entry ]
            [ img
                [ width 60
                , height 45
                , src <| thumbUrl videoId
                , styles Styles.historyThumb
                ]
                []
            , span [] [ text <| truncateText 70 title ]
            , br [] []
            , renderRange startSeconds endSeconds
            ]
        ]


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
