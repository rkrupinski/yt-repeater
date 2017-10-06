port module Ports exposing (..)

import Json.Decode as Decode


port apiReady : (Bool -> msg) -> Sub msg


port videoId : String -> Cmd msg


port videoMeta : (Decode.Value -> msg) -> Sub msg
