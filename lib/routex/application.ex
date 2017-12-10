defmodule Routex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Task.Supervisor, name: Routex.ConnSupervisor},
      {Routex.UDPServer, []},
      Supervisor.child_spec({Task, fn -> Routex.TCPServer.accept() end}, restart: :permanent)
      # Starts a worker by calling: Routex.Worker.start_link(arg)
      # {Routex.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Routex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
