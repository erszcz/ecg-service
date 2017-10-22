defmodule EcgService do
  @moduledoc """
  Documentation for EcgService.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, EcgService.Router, [], [port: 4009])
    ]

    opts = [strategy: :one_for_one, name: EcgService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
