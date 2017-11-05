module Components.Form
    exposing
        ( view
        , init
        , update
        , Model
        , Msg
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit)
import QueryString as QS
import Navigation
import Material
import Material.Textfield as Textfield
import Material.Button as Button
import Material.Options as Options
import Material.Typography as Typography
import Material.Tooltip as Tooltip
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
            , Options.css "width" "150px"
            , Options.id "videoId"
            ]
            []
        , Button.render
            Mdl
            [ 1 ]
            mdl
            [ Button.raised
            , Button.primary
            , Options.css "margin" "0 1em"
            ]
            [ text "Repeat" ]
        , Options.styled span
            [ Typography.caption
            , Options.css "cursor" "help"
            , Options.css "textDecoration" "underline"
            , Tooltip.attach Mdl [ 2 ]
            ]
            [ text "What's video id?" ]
        , Tooltip.render Mdl
            [ 2 ]
            mdl
            [ Tooltip.right
            , Tooltip.large
            , Tooltip.element hackedTooltipLOL
            ]
            [ Options.styled span
                [ Options.css "whiteSpace" "nowrap" ]
                [ text "youtube.com/watch?v="
                , Options.styled span
                    [ Options.css "color" "rgb(255, 82, 82)"
                    , Options.css "fontSize" "1.25em"
                    ]
                    [ text <| String.repeat 11 "X" ]
                ]
            ]
        ]


hackedTooltipLOL : List (Attribute msg) -> List (Html msg) -> Html msg
hackedTooltipLOL attrs children =
    div ([ style [ ( "maxWidth", "none" ) ] ] ++ attrs) children
