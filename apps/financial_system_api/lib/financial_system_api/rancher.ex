defmodule FinancialSystemApi.Rancher do
  @moduledoc false

  use GenServer

  # try to connect every 5 seconds
  @connect_interval 5000

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    name = Application.fetch_env(:financial_system_api, :rancher_service_name)

    case name do
      {:ok, value} ->
        send(self(), :connect)
        {:ok, to_char_list(value)}

      :error ->
        {:ok, []}
    end
  end

  def handle_info(:connect, name) do
    case :inet_tcp.getaddrs(name) do
      {:ok, ips} ->        
        self_ip = Application.get_env(:financial_system_api, :rancher_ip)

        for {a, b, c, d} <- ips do
          if self_ip != "#{a}.#{b}.#{c}.#{d}" do
            Node.connect(:"financial_system_api@#{a}.#{b}.#{c}.#{d}")
          end
        end

      {:error, reason} ->
        IO.puts("Error resolving #{inspect(name)}: #{inspect(reason)}")
    end

    IO.puts("Nodes: #{inspect(Node.list())}")

    Process.send_after(self(), :connect, @connect_interval)

    {:noreply, name}
  end
end
