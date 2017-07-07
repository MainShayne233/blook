module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket


-- APP


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    }


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init websocketRoute
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:update" lobbyName ReceieveUpdate


init : ( Model, Cmd Msg )
init =
    let
        channel =
            Phoenix.Channel.init lobbyName
                |> Phoenix.Channel.onJoin (always (PhoenixResponse lobbyName))
                |> Phoenix.Channel.onClose (always (PhoenixResponse lobbyName))

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initSocket
    in
    ( { phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )


lobbyName : String
lobbyName =
    "game:lobby"


websocketRoute : String
websocketRoute =
    "ws://localhost:4000/socket/websocket"



-- UPDATE


type Msg
    = NoOp
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceieveUpdate Json.Encode.Value
    | PhoenixResponse String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        PhoenixMsg phoenixMsg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update phoenixMsg model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

        ReceieveUpdate update ->
            ( model, Cmd.none )

        PhoenixResponse response ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { phxSocket } =
    Phoenix.Socket.listen phxSocket PhoenixMsg



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ -- inline CSS (literal)
          div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ div [ class "jumbotron" ]
                    [ h2 [] [ text "Phoenix and Elm, hooray!" ]
                    , p [] [ text "find me in assets/elm/Main.elm" ]
                    ]
                ]
            ]
        ]
