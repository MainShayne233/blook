defmodule Blook.Web.GameChannel do
  use Phoenix.Channel

  def join("game:lobby", _params, socket) do
    {:ok, socket}
  end
end
