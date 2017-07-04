defmodule Blook.Web.PageController do
  use Blook.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
