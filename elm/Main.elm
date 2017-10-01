module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Assets


main : Program Never Model msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { title : ( String, String )
    }


init : ( Model, Cmd msg )
init =
    Model ( "YouTube", "repeater" ) ! []


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    model ! []


view : Model -> Html msg
view { title } =
    let
        ( a, b ) =
            title

        url : String
        url =
            Assets.path Assets.logo
    in
        h1 []
            [ img
                [ src url
                , alt a
                , width 100
                ]
                []
            , text " "
            , text b
            ]


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none
