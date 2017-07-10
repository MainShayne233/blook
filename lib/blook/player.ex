defmodule Blook.Player do

  def apply_move(player, move) do
    player
    |> Map.merge(coordinate_adjustment_for_move(player, move))
  end


  defp coordinate_adjustment_for_move(%{yCoordinate: 0}, "up"), do: %{}
  defp coordinate_adjustment_for_move(%{yCoordinate: y}, "up") do
    %{yCoordinate: y - 1}
  end


  defp coordinate_adjustment_for_move(%{yCoordinate: y}, "down") do
    %{yCoordinate: y + 1}
  end


  defp coordinate_adjustment_for_move(%{xCoordinate: 0}, "left"), do: %{}
  defp coordinate_adjustment_for_move(%{xCoordinate: x}, "left") do
    %{xCoordinate: x - 1}
  end


  defp coordinate_adjustment_for_move(%{xCoordinate: x}, "right") do
    %{xCoordinate: x + 1}
  end
end
