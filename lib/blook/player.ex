defmodule Blook.Player do

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

  def apply_move(player, move) do
    player
    |> Map.merge(move_update(player, move))
  end


  ## MOVE


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


  ## ROTATE


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
end
