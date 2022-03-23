defmodule Dnrest do
  use Application

  def start(_type, _args) do
    startDnrest()
  end

  def startDnrest() do
    import Supervisor.Spec, warn: false

    children = [
      {DNS.Cache, []},
      {DNS.DnrestServer, []},
      {Rest.DnrestApi, []}
    ]

    opts = [strategy: :one_for_one, name: Dnrest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
