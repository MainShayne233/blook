defmodule Blook.Web.GameChannel do
  use Phoenix.Channel

  @lobby_name :game_lobby

  def join("game:lobby", _params, socket) do
    {:ok, {player_id, _player}} = Lobby.new_member(@lobby_name)
    Lobby.update_member(@lobby_name, player_id, %{xCoordinate: 0, yCoordinate: 0})
    socket = socket |> assign(:player_id, player_id)
    {:ok, socket}
  end


  def handle_in("fetch:game", _params, socket) do
    {:ok, players} = Lobby.members(@lobby_name)
    broadcast!(socket, "init:game", %{players: players})
    {:noreply, socket}
  end


  def terminate(reason, socket) do
    leaving_player_id =
      socket
      |> Map.get(:assigns)
      |> Map.get(:player_id)

    Lobby.remove_member(@lobby_name, leaving_player_id)
  end
end
