module Router exposing (init, update, getParams, Model, Params, Msg(UrlChange))

import UrlParser as Url exposing ((<?>), parsePath, stringParam, intParam, top)
import Navigation


type Msg
    = UrlChange Navigation.Location


type Model
    = Model
        { params : Params
        }


type alias Params =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


init : Navigation.Location -> Model
init location =
    Model
        { params = extractQueryParams location
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update (UrlChange location) (Model model) =
    Model
        { model
            | params = extractQueryParams location
        }
        ! []


getParams : Model -> Params
getParams (Model { params }) =
    params


parseQueryString : Navigation.Location -> Maybe Params
parseQueryString location =
    let
        queryParser =
            top <?> stringParam "v" <?> intParam "start" <?> intParam "end"
    in
        parsePath (Url.map Params queryParser) location


extractQueryParams : Navigation.Location -> Params
extractQueryParams location =
    let
        defaultParams : Params
        defaultParams =
            Params Nothing Nothing Nothing
    in
        Maybe.withDefault defaultParams <| parseQueryString location
