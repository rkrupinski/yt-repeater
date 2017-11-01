module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import UrlParser as Url exposing ((<?>), parsePath, stringParam, intParam, top)
import Navigation
import Assets
import Styles
import Form
import Player
import Utils exposing (styles, defaultToEmpty)


type Msg
    = FormMsg Form.Msg
    | PlayerMsg Player.Msg
    | UrlChange Navigation.Location


type alias QueryParams =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


type alias Model =
    { videoForm : Maybe Form.Model
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
update msg ({ videoForm, player, queryParams } as model) =
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
            in
                { model
                    | videoForm = videoForm_
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
view ({ videoForm, player } as model) =
    let
        renderForm : Html Msg
        renderForm =
            case videoForm of
                Just videoForm_ ->
                    Html.map FormMsg <| Form.view videoForm_

                _ ->
                    p [] [ text "Loading..." ]

        renderPlayer : Html Msg
        renderPlayer =
            Html.map PlayerMsg <| Player.view player
    in
        div [ styles Styles.container ]
            [ renderHeader
            , renderForm
              -- , renderControls model
            , renderPlayer
            , renderFooter
            ]


renderHeader : Html never
renderHeader =
    let
        logoUrl : String
        logoUrl =
            Assets.path Assets.logo
    in
        header []
            [ h1
                [ styles Styles.heading ]
                [ img
                    [ src logoUrl
                    , alt "YouTube"
                    , styles Styles.logo
                    ]
                    []
                , text " "
                , text "repeater"
                ]
            ]


renderFooter : Html never
renderFooter =
    footer []
        [ a
            [ href "https://github.com/rkrupinski/yt-repeater" ]
            [ text "View source" ]
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
