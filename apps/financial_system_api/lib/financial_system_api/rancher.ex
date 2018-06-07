defmodule FinancialSystemApi.Rancher do
  use GenServer

  # try to connect every 5 seconds
  @connect_interval 5000

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    name = Application.fetch_env!(:financial_system_api, :rancher_service_name)
    send(self, :connect)

    {:ok, to_char_list(name)}
  end

  def handle_info(:connect, name) do
    case :inet_tcp.getaddrs(name) do
      {:ok, ips} ->
        IO.puts("Connecting to #{name}: #{inspect(ips)}")

        for {a, b, c, d} <- ips do
          Node.connect(:"financial_system_api@#{a}.#{b}.#{c}.#{d}")
        end

      {:error, reason} ->
        IO.puts("Error resolving #{inspect(name)}: #{inspect(reason)}")
    end

    IO.puts("Nodes: #{inspect(Node.list())}")
    Process.send_after(self, :connect, @connect_interval)

    {:noreply, name}
  end
end
