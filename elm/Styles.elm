module Styles exposing (..)

import Css exposing (..)


container : List Style
container =
    [ margin <| em 1
    , fontFamily sansSerif
    ]


heading : List Style
heading =
    [ margin3 zero zero <| em 2
    , fontSize <| em 1
    , lineHeight <| em 1
    , fontWeight normal
    ]


logo : List Style
logo =
    [ verticalAlign bottom
    , width <| px 120
    ]


formElement : List Style
formElement =
    [ marginRight <| em 0.5
    , fontSize <| pct 100
    ]


section : List Style
section =
    [ marginBottom <| em 1
    ]
