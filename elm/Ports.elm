port module Ports exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode


port amendHistory : Encode.Value -> Cmd msg


port clearHistory : Encode.Value -> Cmd msg


port readHistory : (Decode.Value -> msg) -> Sub msg
