port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Styles exposing (slider)
import Css.Normalize


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "normalize.css", Css.File.compile [ Css.Normalize.css ] )
        , ( "slider.css", Css.File.compile [ slider ] )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
