module Layout.Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Icon as Icon
import Material.Options as Options


view : Html never
view =
    footer []
        [ a
            [ href "https://github.com/rkrupinski/yt-repeater" ]
            [ Icon.view
                "code"
                [ Icon.size24
                , Options.css "verticalAlign" "middle"
                , Options.css "marginRight" ".25em"
                ]
            , text "Browse source"
            ]
        ]
