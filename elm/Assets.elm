module Assets exposing (..)


type AssetPath
    = AssetPath String


path : AssetPath -> String
path (AssetPath str) =
    str


logo : AssetPath
logo =
    AssetPath "yt.svg"
