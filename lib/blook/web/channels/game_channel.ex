defmodule Blook.Web.GameChannel do
  use Phoenix.Channel
  alias Blook.Player

  @lobby_name :game_lobby

  def join("game:lobby", _params, socket) do
    {:ok, {player_id, _player}} = Lobby.new_member(@lobby_name)
    Lobby.update_member(@lobby_name, player_id, %{xCoordinate: 0, yCoordinate: 0})
    socket = socket |> assign(:player_id, player_id)
    {:ok, socket}
  end


  def handle_in("fetch:game", _params, socket) do
    broadcast_game(socket)
    {:noreply, socket}
  end


  def handle_in("new:move", %{"move" => move}, socket) do
    player_id = player_id(socket)
    {:ok, player} = Lobby.get_member(@lobby_name, player_id)
    updated_player = Player.apply_move(player, move)
    Lobby.update_member(@lobby_name, player_id, updated_player)
    broadcast_game(socket)
    {:noreply, socket}
  end


  def terminate(_reason, socket) do
    leaving_player_id = player_id(socket)
    Lobby.remove_member(@lobby_name, leaving_player_id)
    broadcast_game(socket)
  end


  defp broadcast_game(socket) do
    {:ok, players} = Lobby.members(@lobby_name)
    broadcast!(socket, "update:game", %{players: players})
  end


  defp player_id(socket) do
    socket
    |> Map.get(:assigns)
    |> Map.get(:player_id)
  end
end
