module Main exposing (..)

import Html exposing (..)
import Navigation
import Material.Scheme as Scheme
import Material.Color as Color
import Router
import Layout.Header as Header
import Layout.Footer as Footer
import Components.Form as Form
import Components.Controls as Controls
import Components.Player as Player
import Utils exposing (styles)
import Styles


type Msg
    = FormMsg Form.Msg
    | ControlsMsg Controls.Msg
    | PlayerMsg Player.Msg
    | RouterMsg Router.Msg
    | UrlChange Navigation.Location


type alias Model =
    { videoForm : Maybe Form.Model
    , videoControls : Maybe Controls.Model
    , player : Player.Model
    , router : Router.Model
    }


baseUrl : Router.Url
baseUrl =
    ""


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        router : Router.Model
        router =
            Router.init baseUrl location

        params : Router.Params
        params =
            Router.getParams router
    in
        Model
            Nothing
            Nothing
            (Player.init params)
            router
            ! []


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ videoForm, videoControls, player, router } as model) =
    case msg of
        FormMsg formMsg ->
            case videoForm of
                Just videoForm_ ->
                    let
                        ( newForm, cmd ) =
                            Form.update formMsg videoForm_
                    in
                        { model
                            | videoForm = Just newForm
                        }
                            ! [ Cmd.map FormMsg cmd ]

                _ ->
                    model ! []

        ControlsMsg controlsMsg ->
            case videoControls of
                Just videoControls_ ->
                    let
                        ( newControls, cmd ) =
                            Controls.update controlsMsg videoControls_
                    in
                        { model
                            | videoControls = Just newControls
                        }
                            ! [ Cmd.map ControlsMsg cmd ]

                _ ->
                    model ! []

        PlayerMsg playerMsg ->
            let
                ( player_, cmd ) =
                    Player.update playerMsg player

                ({ v } as params) =
                    Router.getParams router

                videoForm_ : Maybe Form.Model
                videoForm_ =
                    case
                        ( Player.getApiReady player
                        , Player.getApiReady player_
                        )
                    of
                        ( False, True ) ->
                            Form.init v |> Just

                        _ ->
                            videoForm

                videoControls_ : Maybe Controls.Model
                videoControls_ =
                    case (Player.getVideoDuration player_) of
                        Just duration ->
                            Controls.init duration params |> Just

                        _ ->
                            videoControls
            in
                { model
                    | videoForm = videoForm_
                    , videoControls = videoControls_
                    , player = player_
                }
                    ! [ Cmd.map PlayerMsg cmd ]

        RouterMsg _ ->
            model ! []

        UrlChange location ->
            let
                ( router_, routerCmd ) =
                    Router.update (Router.UrlChange location) router

                params : Router.Params
                params =
                    Router.getParams router_

                ( player_, playerCmd ) =
                    Player.update (Player.SetParams params) player
            in
                { model
                    | player = player_
                    , router = router_
                }
                    ! [ Cmd.map PlayerMsg playerCmd
                      , Cmd.map RouterMsg routerCmd
                      ]


view : Model -> Html Msg
view ({ videoForm, videoControls, player } as model) =
    let
        renderForm : Html Msg
        renderForm =
            case videoForm of
                Just videoForm_ ->
                    Html.map FormMsg <| Form.view videoForm_

                _ ->
                    text ""

        renderControls : Html Msg
        renderControls =
            case videoControls of
                Just videoControls_ ->
                    Html.map ControlsMsg <| Controls.view videoControls_

                _ ->
                    text ""
    in
        Scheme.topWithScheme Color.BlueGrey Color.Red <|
            div [ styles Styles.container ]
                [ Header.view
                , renderForm
                , renderControls
                , Html.map PlayerMsg <| Player.view player
                , Footer.view
                ]


subscriptions : Model -> Sub Msg
subscriptions { videoControls } =
    case videoControls of
        Just videoControls_ ->
            Sub.map ControlsMsg <| Controls.subscriptions videoControls_

        _ ->
            Sub.none
