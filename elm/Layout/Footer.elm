module Layout.Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html never
view =
    footer []
        [ a
            [ href "https://github.com/rkrupinski/yt-repeater" ]
            [ text "View source" ]
        ]
