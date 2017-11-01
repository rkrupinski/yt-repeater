module Layout.Header exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Assets
import Styles
import Utils exposing (styles)


view : Html never
view =
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
