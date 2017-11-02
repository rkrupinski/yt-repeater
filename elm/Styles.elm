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


slider : Stylesheet
slider =
    (stylesheet << namespace "slider")
        [ class Slider
            [ display inlineBlock
            , height <| px 6
            , margin4 zero (em 1) zero zero
            , borderRadius <| px 3
            , position relative
            , backgroundColor silver
            ]
        , class Knob
            [ width <| px 12
            , height <| px 12
            , marginTop <| px -3
            , borderRadius <| px 6
            , position absolute
            , zIndex <| int 2
            , backgroundColor <| rgb 255 82 82
            , cursor pointer
            ]
        , class LeftKnob
            [ marginLeft <| px -6
            ]
        , class RightKnob
            [ marginLeft <| px -6
            ]
        , class Range
            [ height <| px 6
            , position absolute
            , top zero
            , backgroundColor <| rgb 96 125 139
            ]
        ]
