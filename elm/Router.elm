module Router exposing (init, update, getParams, getBaseUrl, Model, Params, Msg(UrlChange), Url)

import UrlParser as Url exposing ((<?>), parsePath, stringParam, intParam, s)
import Navigation


type Msg
    = UrlChange Navigation.Location


type alias Url =
    String


type Model
    = Model
        { baseUrl : Url
        , params : Params
        }


type alias Params =
    { v : Maybe String
    , start : Maybe Int
    , end : Maybe Int
    }


init : Url -> Navigation.Location -> Model
init baseUrl location =
    Model
        { baseUrl = baseUrl
        , params = extractQueryParams baseUrl location
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update (UrlChange location) (Model ({ baseUrl } as model)) =
    Model
        { model
            | params = extractQueryParams baseUrl location
        }
        ! []


getParams : Model -> Params
getParams (Model { params }) =
    params


getBaseUrl : Model -> Url
getBaseUrl (Model { baseUrl }) =
    baseUrl


parseQueryString : Url -> Navigation.Location -> Maybe Params
parseQueryString baseUrl location =
    let
        queryParser =
            s baseUrl <?> stringParam "v" <?> intParam "start" <?> intParam "end"
    in
        parsePath (Url.map Params queryParser) location


extractQueryParams : Url -> Navigation.Location -> Params
extractQueryParams baseUrl location =
    let
        defaultParams : Params
        defaultParams =
            Params Nothing Nothing Nothing
    in
        Maybe.withDefault defaultParams <| parseQueryString baseUrl location
