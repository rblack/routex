defmodule Routex.UDPServer do
  use GenServer
  require Logger

  def start_link(_) do
    ip = Application.get_env(:udp_server, :ip, {127,0,0,1})
    port = Application.get_env(:udp_server, :port, 1515)
    GenServer.start_link(__MODULE__, [%{ip: ip, port: port, socket: nil}], name: __MODULE__)
  end

  def init([state]) do
    {:ok, socket} = :gen_udp.open(state.port, [:binary, :inet,
      {:ip, state.ip},
      {:active, true}])
    {:ok, port} = :inet.port(socket)
    Logger.info("Started UDP on #{:inet.ntoa(state.ip)}:#{port}")
    {:ok, %{state | socket: socket, port: port}}
  end

  def terminate(_reason, %{socket: socket} = state) when socket != nil do
    Logger.info("closing port #{state.port}")
    :ok = :gen_udp.close(socket)
  end

  def handle_info({:udp, _, _, _, _} = message, state) do
    {:ok, _pid} = Task.Supervisor.start_child(Routex.ConnSupervisor, fn
      -> send_resp(message)
    end)
    {:noreply, state}
  end

  def send_resp({:udp, socket, ip, fromport, packet}) do
    start_t = System.monotonic_time(:microsecond)
    resp = Routex.DNS.make_resp(packet)
    :gen_udp.send(socket, ip, fromport, resp)
    end_t = System.monotonic_time(:microsecond)
    Logger.info("Response time #{end_t - start_t}μs")
  end

end