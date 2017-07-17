defmodule Blook.Player do

  @kinetic_moves [
    "move_up",
    "move_down",
    "move_left",
    "move_right",
    "rotate_clockwise",
    "rotate_counter_clockwise",
  ]

  @event_moves [
    "shoot",
  ]

  @directions [
    "up",
    "right",
    "down",
    "left",
  ]

  @move_magnitude 2

  def init do
    %{
      xDisplacement: 0,
      yDisplacement: 0,
      direction: "right",
    }
  end


  def handle_move(player, move) when move in @kinetic_moves do
    player = Map.merge(player, move_update(player, move))
    {:change, player}
  end


  def handle_move(player, move) when move in @event_moves do
    handle_event(player, move)
    {:no_change, player}
  end


  ## KINETIC MOVES


  defp move_update(%{yDisplacement: 0}, "move_up"), do: %{}
  defp move_update(%{yDisplacement: y}, "move_up") do
    %{yDisplacement: y - @move_magnitude}
  end


  defp move_update(%{yDisplacement: y}, "move_down") do
    %{yDisplacement: y + @move_magnitude}
  end


  defp move_update(%{xDisplacement: 0}, "move_left"), do: %{}
  defp move_update(%{xDisplacement: x}, "move_left") do
    %{xDisplacement: x - @move_magnitude}
  end


  defp move_update(%{xDisplacement: x}, "move_right") do
    %{xDisplacement: x + @move_magnitude}
  end


  defp move_update(%{direction: direction}, "rotate_clockwise") do
    %{direction: next_direction(direction, @directions)}
  end


  defp move_update(%{direction: direction}, "rotate_counter_clockwise") do
    %{direction: next_direction(direction, Enum.reverse(@directions))}
  end


  defp next_direction(direction, directions) do
    index =
      directions
      |> Enum.find_index(&(&1 == direction))
      |> Kernel.+(1)
      |> rem(4)

    Enum.at(directions, index)
  end


  ## EVENT MOVES


  defp handle_event(player, "shoot") do
    broadcast_event(player, "player:shoot")
  end


  defp broadcast_event(payload, event_name) do
    Blook.Web.Endpoint.broadcast!("game:lobby", event_name, payload)
  end
end
