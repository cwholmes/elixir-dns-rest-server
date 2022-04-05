defmodule DNS.DnrestServer do
  @moduledoc """
  Simple DNS Server that responds with cached responses.
  """
  use GenServer

  require Logger
  require DNS.Records

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    otp_options = Application.get_env(:elixir_dns_rest_server, __MODULE__, [])
    # A port will be auto assigned by the os for 0
    port = otp_options[:dns_port] || 0
    Logger.debug("DNS Server listening at #{port}")
    {:ok, socket} = :gen_udp.open(port, [:binary, active: true])
    {:ok, port} = :inet.port(socket)

    System.put_env("DNS_PORT", to_string(port))

    # accept_loop(socket, handler)
    {:ok, %{port: port, socket: socket}}
  end

  def handle_info({:udp, _client, ip, wtv, data}, state) do
    {:ok, erl_record} = :inet_dns.decode(data)
    response = handle(DNS.Records.to_map(erl_record))
    :ok = :gen_udp.send(state.socket, ip, wtv, :inet_dns.encode(response))
    {:noreply, state}
  end

  defp handle(%{header: header, qdlist: qdlist} = record) do
    # see dns_rec definition here https://github.com/erlang/otp/blob/master/lib/kernel/src/inet_dns.hrl
    Logger.debug("Request Questions:")
    Logger.debug(fn -> "#{inspect(qdlist)}" end)
    query = hd(qdlist)

    resource =
      try do
        getRecordFromCache(DNS.Records.to_map(query))
      rescue
        # If there is a failure we just need to return empty answers.
        e ->
          Logger.debug(Exception.format(:error, e, __STACKTRACE__))
          []
      end

    Logger.debug("Answer List:")
    Logger.debug(fn -> "#{inspect(resource)}" end)

    try do
      record
      |> Map.put(:header, put_elem(header, 2, true))
      |> Map.put(:anlist, resource)
      |> DNS.Records.to_record(:dns_rec)
    rescue
      err ->
        Logger.error(Exception.format(:error, err, __STACKTRACE__))
        raise err
    end
  end

  defp getRecordFromCache(%{domain: domain, type: type, class: class} = _query) do
    case type do
      :a ->
        case DNS.Cache.get_record(:a, domain |> DNS.Cache.canonicalize()) do
          nil ->
            []

          value ->
            case value |> DNS.IP_Utils.to_ipv4() do
              {:ok, address} ->
                [makeResource(address, domain, type, class)]

              {:error, item} ->
                Logger.debug(fn -> "Failed to find the IPv4 address <#{item}>" end)
                []
            end
        end

      :cname ->
        makeResource(domain |> DNS.Cache.canonicalize(), domain, type, class)

      :srv ->
        case DNS.Cache.get_record(:srv, domain |> DNS.Cache.canonicalize()) do
          nil -> []
          value -> Enum.map(value, fn data -> makeResource(data, domain, type, class) end)
        end

      _ ->
        []
    end
  end

  defp makeResource(data, domain, type, class) do
    # see definition here https://github.com/erlang/otp/blob/master/lib/kernel/src/inet_dns.hrl
    DNS.Records.dns_rr(domain: domain, data: data, type: type, class: class)
  end
end
