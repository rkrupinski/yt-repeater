module Styles exposing (..)

import Css exposing (..)
import Css.Colors exposing (..)
import Css.Namespace exposing (namespace)
import Slider.ClassNames exposing (..)


container : List Style
container =
    [ margin <| em 1
    ]


heading : List Style
heading =
    [ margin3 zero zero <| em 2
    , fontSize <| em 1
    , lineHeight <| int 1
    , fontWeight normal
    ]


logo : List Style
logo =
    [ verticalAlign bottom
    , width <| px 120
    ]


player : List Style
player =
    [ width <| px 560
    ]


history : List Style
history =
    [ listStyle none
    , padding zero
    ]


historyEntry : List Style
historyEntry =
    [ marginBottom <| em 1
    , overflow hidden
    , lineHeight <| em 1.6
    ]


historyThumb : List Style
historyThumb =
    [ marginRight <| em 1
    , float left
    ]


historyRange : List Style
historyRange =
    [ display inlineBlock
    , fontSize <| em 0.85
    , textDecoration none
    , color gray
    ]


slider : Stylesheet
slider =
    (stylesheet << namespace "slider")
        [ class Slider
            [ display inlineBlock
            , verticalAlign middle
            , height <| px 2
            , marginRight <| em 1
            , position relative
            , backgroundColor silver
            ]
        , class Knob
            [ width <| px 12
            , height <| px 12
            , marginTop <| px -5
            , borderRadius <| px 6
            , position absolute
            , zIndex <| int 2
            , backgroundColor <| rgb 96 125 139
            , cursor pointer
            ]
        , class LeftKnob
            [ marginLeft <| px -6
            ]
        , class RightKnob
            [ marginLeft <| px -6
            ]
        , class Range
            [ height <| px 2
            , position absolute
            , top zero
            , backgroundColor <| rgb 96 125 139
            ]
        ]
