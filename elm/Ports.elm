port module Ports exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


port apiReady : (Bool -> msg) -> Sub msg


port videoId : String -> Cmd msg


port videoMeta : (Decode.Value -> msg) -> Sub msg


port range : Encode.Value -> Cmd msg
