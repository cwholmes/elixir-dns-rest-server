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
    response = handle(erl_record)
    :gen_udp.send(state.socket, ip, wtv, :inet_dns.encode(response))
    {:noreply, state}
  end

  defp handle({:dns_rec, header, qdlist, _anlist, nslist, arlist}) do
    # see dns_rec definition here https://github.com/erlang/otp/blob/master/lib/kernel/src/inet_dns.hrl
    Logger.debug("Request Questions:")
    Logger.debug(fn -> "#{inspect(qdlist)}" end)
    query = hd(qdlist)

    resource =
      try do
        getRecordFromCache(Tuple.to_list(query))
      rescue
        # If there is a failure we just need to return empty answers.
        e ->
          Logger.debug(Exception.format(:error, e, __STACKTRACE__))
          []
      end

    Logger.debug("Answer List:")
    Logger.debug(fn -> "#{inspect(resource)}" end)

    {:dns_rec, put_elem(header, 2, true), qdlist, resource, nslist, arlist}
  end

  defp getRecordFromCache([:dns_query, domain, type, class | _]) do
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
    {
      :dns_rr,
      # domain
      domain,
      # type
      type,
      # class
      class,
      # cnt
      0,
      # ttl
      0,
      # data
      data,
      # tm
      :undefined,
      # bm
      [],
      # func
      false
    }
  end
end
