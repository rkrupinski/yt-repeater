module Components.Form exposing (view, init, update, Model, Msg)

import Html exposing (..)
import Html.Events exposing (onSubmit)
import QueryString as QS
import Navigation
import Material
import Material.Textfield as Textfield
import Material.Button as Button
import Material.Options as Options
import Utils exposing (defaultToEmpty)


type Msg
    = InputVideoId VideoId
    | SubmitVideoId
    | Mdl (Material.Msg Msg)


type alias VideoId =
    String


type Model
    = Model
        { videoId : Maybe VideoId
        , mdl : Material.Model
        }


init : Maybe VideoId -> Model
init videoId =
    Model
        { videoId = videoId
        , mdl = Material.model
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

        Mdl mdlMsg ->
            let
                ( model_, cmd ) =
                    Material.update Mdl mdlMsg model
            in
                Model model_ ! [ cmd ]


view : Model -> Html Msg
view (Model { videoId, mdl }) =
    Html.form
        [ onSubmit SubmitVideoId
        ]
        [ Textfield.render
            Mdl
            [ 0 ]
            mdl
            [ Textfield.label "Video id"
            , Textfield.floatingLabel
            , Textfield.text_
            , Textfield.value <| defaultToEmpty videoId
            , Options.onInput InputVideoId
            , Options.css "marginRight" "1em"
            , Options.css "width" "200px"
            , Options.id "videoId"
            ]
            []
        , Button.render
            Mdl
            [ 1 ]
            mdl
            [ Button.raised
            , Button.primary
            ]
            [ text "Load" ]
        ]
