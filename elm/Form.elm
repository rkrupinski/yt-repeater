module Form exposing (view, init, update, Model, Msg)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import QueryString as QS
import Navigation
import Utils exposing (styles, defaultToEmpty)
import Styles


type Msg
    = InputVideoId String
    | SubmitVideoId


type alias VideoId =
    String


type Model
    = Model
        { videoId : Maybe VideoId
        }


init : Maybe VideoId -> Model
init videoId =
    Model
        { videoId = videoId
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        InputVideoId newId ->
            Model { model | videoId = Just newId } ! []

        SubmitVideoId ->
            let
                newUrl : String
                newUrl =
                    QS.empty
                        |> QS.add "v" (defaultToEmpty model.videoId)
                        |> QS.render
            in
                Model model ! [ Navigation.modifyUrl newUrl ]


view : Model -> Html Msg
view (Model { videoId }) =
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
