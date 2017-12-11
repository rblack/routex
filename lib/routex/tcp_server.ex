defmodule Routex.TCPServer do
  require Logger

  def accept() do
    ip = Application.get_env(:udp_server, :ip, {127,0,0,1})
    port = Application.get_env(:udp_server, :port, 1515)
    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, {:packet, 2}, {:ip, ip}, active: false, reuseaddr: true])
    Logger.info("Started TCP on #{:inet.ntoa(ip)}:#{port}")
    accept_loop(socket)
  end

  def accept_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Routex.ConnSupervisor, fn -> send_resp(client) end)
    case :gen_tcp.controlling_process(client, pid) do
      :ok -> Logger.debug("Ctrl proc ok")
      {:error, :badarg} -> Logger.warn("Ctrl proc bad arg")
    end
    accept_loop(socket)
  end

  defp send_resp(socket) do
    :timer.sleep(2) # process exits before :gen_tcp.controlling_process(client, pid)
    start_t = System.monotonic_time(:microsecond)
    {:ok, packet} = :gen_tcp.recv(socket, 0)
    resp = Routex.DNS.make_resp(packet)
    end_t = System.monotonic_time(:microsecond)
    :gen_tcp.send(socket, resp)
    Logger.info("Response time #{end_t - start_t}μs")
  end

end
