port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Styles exposing (slider)


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "slider.css", Css.File.compile [ slider ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
