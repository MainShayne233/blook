defmodule Blook.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Blook.Web.Endpoint, []),
      supervisor(Lobby, [:game_lobby]),
    ]

    opts = [strategy: :one_for_one, name: Blook.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
