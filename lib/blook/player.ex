defmodule Blook.Player do

  def apply_move(player, move) do
    player
    |> Map.merge(coordinate_adjustment_for_move(player, move))
  end


  defp coordinate_adjustment_for_move(%{yDisplacement: 0}, "up"), do: %{}
  defp coordinate_adjustment_for_move(%{yDisplacement: y}, "up") do
    %{yDisplacement: y - 1}
  end


  defp coordinate_adjustment_for_move(%{yDisplacement: y}, "down") do
    %{yDisplacement: y + 1}
  end


  defp coordinate_adjustment_for_move(%{xDisplacement: 0}, "left"), do: %{}
  defp coordinate_adjustment_for_move(%{xDisplacement: x}, "left") do
    %{xDisplacement: x - 1}
  end


  defp coordinate_adjustment_for_move(%{xDisplacement: x}, "right") do
    %{xDisplacement: x + 1}
  end
end
