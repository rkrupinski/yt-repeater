module Main exposing (..)

import Html exposing (..)
import UrlParser as Url exposing ((<?>), parsePath, stringParam, intParam, top)
import Navigation
import Layout.Header as Header
import Layout.Footer as Footer
import Components.Form as Form
import Components.Controls as Controls
import Components.Player as Player


type Msg
    = FormMsg Form.Msg
    | ControlsMsg Controls.Msg
    | PlayerMsg Player.Msg
    | UrlChange Navigation.Location


type alias QueryParams =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


type alias Model =
    { videoForm : Maybe Form.Model
    , videoControls : Maybe Controls.Model
    , player : Player.Model
    , queryParams : QueryParams
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        queryParams : QueryParams
        queryParams =
            extractQueryParams location
    in
        Model
            Nothing
            Nothing
            (Player.init queryParams)
            queryParams
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
update msg ({ videoForm, videoControls, player, queryParams } as model) =
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
            -- TODO
            model ! []

        PlayerMsg playerMsg ->
            let
                ( player_, cmd ) =
                    Player.update playerMsg player

                videoForm_ : Maybe Form.Model
                videoForm_ =
                    case
                        ( Player.getApiReady player
                        , Player.getApiReady player_
                        )
                    of
                        ( False, True ) ->
                            let
                                { v } =
                                    queryParams
                            in
                                Form.init v |> Just

                        _ ->
                            videoForm

                videoControls_ : Maybe Controls.Model
                videoControls_ =
                    case (Player.getVideoDuration player_) of
                        Just duration ->
                            Controls.init |> Just

                        _ ->
                            videoControls
            in
                { model
                    | videoForm = videoForm_
                    , videoControls = videoControls_
                    , player = player_
                }
                    ! [ Cmd.map PlayerMsg cmd ]

        UrlChange location ->
            let
                queryParams : QueryParams
                queryParams =
                    extractQueryParams location

                ( player_, cmd ) =
                    Player.update (Player.SetParams queryParams) player
            in
                { model
                    | player = player_
                    , queryParams = queryParams
                }
                    ! [ Cmd.map PlayerMsg cmd ]


view : Model -> Html Msg
view ({ videoForm, videoControls, player } as model) =
    let
        renderForm : Html Msg
        renderForm =
            case videoForm of
                Just videoForm_ ->
                    Html.map FormMsg <| Form.view videoForm_

                _ ->
                    p [] [ text "Loading..." ]

        renderControls : Html Msg
        renderControls =
            case videoControls of
                Just videoControls_ ->
                    Html.map ControlsMsg <| Controls.view videoControls_

                _ ->
                    text ""
    in
        div []
            [ Header.view
            , renderForm
            , renderControls
            , Html.map PlayerMsg <| Player.view player
            , Footer.view
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


parseQueryString : Navigation.Location -> Maybe QueryParams
parseQueryString location =
    let
        queryParser =
            top <?> stringParam "v" <?> intParam "start" <?> intParam "end"
    in
        parsePath (Url.map QueryParams queryParser) location


extractQueryParams : Navigation.Location -> QueryParams
extractQueryParams location =
    let
        defaultParams : QueryParams
        defaultParams =
            QueryParams Nothing Nothing Nothing
    in
        Maybe.withDefault defaultParams <| parseQueryString location
