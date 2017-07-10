port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode
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
    , players : List Player
    }


type alias Player =
    { xCoordinate : Float
    , yCoordinate : Float
    }


type alias Game =
    { players : List Player
    }


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init websocketRoute
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "update:game" lobbyName GameUpdate


init : ( Model, Cmd Msg )
init =
    let
        channel =
            Phoenix.Channel.init lobbyName
                |> Phoenix.Channel.onJoin (always PhoenixJoin)
                |> Phoenix.Channel.onClose (always (PhoenixResponse lobbyName))

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initSocket
    in
    ( { phxSocket = phxSocket, players = [] }
    , Cmd.map PhoenixMsg phxCmd
    )


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
    | ReceiveUpdate Json.Encode.Value
    | PhoenixResponse String
    | PhoenixJoin
    | GameUpdate Json.Encode.Value
    | NewMove String


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

        ReceiveUpdate update ->
            ( model, Cmd.none )

        PhoenixJoin ->
            let
                push_ =
                    Phoenix.Push.init "fetch:game" "game:lobby"

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

        PhoenixResponse response ->
            ( model, Cmd.none )

        GameUpdate payload ->
            case Json.Decode.decodeValue gameDecoder payload of
                Ok game ->
                    ( { model | players = game.players }, Cmd.none )

                Err error ->
                    let
                        _ =
                            Debug.log "GameUpdate error" error
                    in
                    ( model, Cmd.none )

        NewMove move ->
            let
                payload =
                    Json.Encode.object [ ( "move", Json.Encode.string move ) ]

                push =
                    Phoenix.Push.init "new:move" "game:lobby"
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )



-- DECODERS


gameDecoder : Json.Decode.Decoder Game
gameDecoder =
    Json.Decode.map Game
        (Json.Decode.field "players" (Json.Decode.list playerDecoder))


playerDecoder : Json.Decode.Decoder Player
playerDecoder =
    Json.Decode.map2 Player
        (Json.Decode.field "xCoordinate" Json.Decode.float)
        (Json.Decode.field "yCoordinate" Json.Decode.float)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { phxSocket } =
    Sub.batch
        [ Phoenix.Socket.listen phxSocket PhoenixMsg
        , newMove NewMove
        ]


port newMove : (String -> msg) -> Sub msg



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view { players } =
    div []
        [ h1 [] [ text "Blook" ]
        , div [] (renderPlayers players)
        ]


renderPlayers : List Player -> List (Html Msg)
renderPlayers players =
    List.map renderPlayer players


renderPlayer : Player -> Html Msg
renderPlayer player =
    div [ playerStyle player, class "player" ] []



-- STYLE


playerStyle : Player -> Html.Attribute msg
playerStyle { xCoordinate, yCoordinate } =
    style
        [ ( "position", "absolute" )
        , ( "height", "50px" )
        , ( "width", "50px" )
        , ( "backgroundColor", "black" )
        , ( "marginLeft", ((xCoordinate * 10) |> toString) ++ "px" )
        , ( "marginTop", ((yCoordinate * 10) |> toString) ++ "px" )
        ]
