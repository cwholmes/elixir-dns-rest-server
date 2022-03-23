defmodule DNS.DnrestServer do
  @moduledoc """
  Simple DNS Server that responds with cached responses.
  """
  use GenServer

  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    otp_options = Application.get_env(:elixir_dns_server, __MODULE__, [])
    port = otp_options[:dns_port] || 0 # A port will be auto assigned by the os for 0
    Logger.debug("DNS Server listening at #{port}")
    socket = Socket.UDP.open!(port, as: :binary, mode: :active)
    {:ok, port} = :inet.port(socket)

    System.put_env("DNS_PORT", to_string(port))

    # accept_loop(socket, handler)
    {:ok, %{port: port, socket: socket}}
  end

  def handle_info({:udp, client, ip, wtv, data}, state) do
    record = DNS.Record.decode(data)
    response = handle(record, client)
    Socket.Datagram.send!(state.socket, DNS.Record.encode(response), {ip, wtv})
    {:noreply, state}
  end

  defp handle(record, _cl) do
    Logger.debug("Request Record:")
    Logger.debug(fn -> "#{inspect(record)}" end)
    query = hd(record.qdlist)

    resource = try do
      getRecordFromCache(query)
    rescue
       # If there is a failure we just need to return empty answers.
       e -> []
    end

    Logger.debug("Answer List:")
    Logger.debug(fn -> "#{inspect(resource)}" end)

    %{record | anlist: resource, header: %{record.header | qr: true}}
  end

  defp getRecordFromCache(query) do
    case query.type do
      :a ->
        case DNS.Cache.get_record(:a, to_string(query.domain) |> DNS.Cache.canonicalize) do
          nil -> []
          value ->
            case value |> DNS.IP_Utils.to_ipv4 do
              {:ok, address} ->
                [makeResource(address, query)]
              {:error, item} ->
                Logger.debug(fn -> "Failed to find the IPv4 address <#{item}>" end)
                []
            end
        end
      :cname ->
        makeResource(System.get_env("DEFAULT_DNS_SUFFIX"), query)
      :srv ->
        case DNS.Cache.get_record(:srv, query.domain |> to_string |> DNS.Cache.canonicalize) do
          nil -> []
          value -> Enum.map(value, fn data -> makeResource(data, query) end)
        end
      _ -> []
    end
  end

  defp makeResource(data, query) do
    %DNS.Resource{
      domain: query.domain,
      class: query.class,
      type: query.type,
      ttl: 0,
      data: data
    }
  end
end
