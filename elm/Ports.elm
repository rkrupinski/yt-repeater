port module Ports exposing (addToHistory)

import Json.Encode as Encode
import Json.Decode as Decode


port addToHistory : Encode.Value -> Cmd msg


port readHistory : (Decode.Value -> msg) -> Sub msg
