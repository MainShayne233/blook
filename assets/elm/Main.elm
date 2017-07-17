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
    , shots : List Shot
    }


type alias Player =
    { xDisplacement : Float
    , yDisplacement : Float
    , direction : Direction
    }


type alias Shot =
    { xDisplacement : Float
    , yDisplacement : Float
    , direction : Direction
    , duration : Int
    }


type Direction
    = Up
    | Down
    | Left
    | Right


type alias Game =
    { players : List Player
    }


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init websocketRoute
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "update:game" lobbyName GameUpdate
        |> Phoenix.Socket.on "player:shoot" lobbyName PlayerShoot


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
    ( { phxSocket = phxSocket, players = [], shots = [] }
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
    | PlayerShoot Json.Encode.Value


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

        PlayerShoot player ->
            case playerShot player of
                Ok newShot ->
                    ( { model | shots = newShot :: model.shots }, Cmd.none )

                other_ ->
                    ( model, Cmd.none )



-- DECODERS


playerShot : Json.Decode.Value -> Result Shot Shot
playerShot player =
    case Json.Decode.decodeValue playerDecoder player of
        Ok player ->
            Ok (doPlayerShot player)

        Err player_ ->
            Err (Shot 0 0 Up 0)


doPlayerShot : Player -> Shot
doPlayerShot player =
    Shot (shotXDiplacement player) (shotYDiplacement player) player.direction 500


shotXDiplacement : Player -> Float
shotXDiplacement { xDisplacement, direction } =
    xDisplacement


shotYDiplacement : Player -> Float
shotYDiplacement { yDisplacement, direction } =
    yDisplacement


gameDecoder : Json.Decode.Decoder Game
gameDecoder =
    Json.Decode.map Game
        (Json.Decode.field "players" (Json.Decode.list playerDecoder))


playerDecoder : Json.Decode.Decoder Player
playerDecoder =
    Json.Decode.map3 Player
        (Json.Decode.field "xDisplacement" Json.Decode.float)
        (Json.Decode.field "yDisplacement" Json.Decode.float)
        (Json.Decode.field "direction" directionDecoder)


directionDecoder : Json.Decode.Decoder Direction
directionDecoder =
    stringToTypeDecoder decodeDirection


decodeDirection : String -> Direction
decodeDirection direction =
    case direction of
        "up" ->
            Up

        "down" ->
            Down

        "left" ->
            Left

        "right" ->
            Right

        _ ->
            Right


stringToTypeDecoder : (String -> a) -> Json.Decode.Decoder a
stringToTypeDecoder decoder =
    Json.Decode.string
        |> Json.Decode.andThen (doStringToTypeDecoding decoder)


doStringToTypeDecoding : (String -> a) -> String -> Json.Decode.Decoder a
doStringToTypeDecoding decoder string =
    Json.Decode.succeed (decoder string)



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
    div [ playerStyle player, class "player" ]
        [ div [ cannonStyle player, class "cannon" ] []
        ]



-- STYLE


playerStyle : Player -> Html.Attribute msg
playerStyle { xDisplacement, yDisplacement } =
    style
        [ ( "position", "absolute" )
        , ( "height", "50px" )
        , ( "width", "50px" )
        , ( "backgroundColor", "black" )
        , ( "marginLeft", ((xDisplacement * 10) |> toString) ++ "px" )
        , ( "marginTop", ((yDisplacement * 10) |> toString) ++ "px" )
        ]


cannonStyle : Player -> Html.Attribute msg
cannonStyle { direction } =
    let
        baseStyle =
            [ ( "position", "absolute" )
            , ( "height", "10px" )
            , ( "width", "10px" )
            , ( "backgroundColor", "red" )
            , ( "z-index", "-1" )
            ]

        directionStyle =
            case direction of
                Up ->
                    [ ( "margin-top", "-10px" )
                    , ( "margin-left", "20px" )
                    ]

                Right ->
                    [ ( "margin-top", "20px" )
                    , ( "margin-left", "50px" )
                    ]

                Down ->
                    [ ( "margin-top", "50px" )
                    , ( "margin-left", "20px" )
                    ]

                Left ->
                    [ ( "margin-top", "20px" )
                    , ( "margin-left", "-10px" )
                    ]
    in
    style (baseStyle ++ directionStyle)
