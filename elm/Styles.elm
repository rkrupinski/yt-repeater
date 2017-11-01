module Styles exposing (..)

import Css exposing (..)
import Css.Colors exposing (..)
import Css.Namespace exposing (namespace)
import Slider.ClassNames exposing (..)


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


formElement : List Style
formElement =
    [ marginRight <| em 0.5
    , fontSize <| pct 100
    ]


section : List Style
section =
    [ marginBottom <| em 1
    ]


slider : Stylesheet
slider =
    (stylesheet << namespace "slider")
        [ class Slider
            [ height <| px 6
            , margin2 (em 1) zero
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
            , backgroundColor black
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
            , backgroundColor gray
            ]
        ]
