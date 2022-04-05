defmodule DNS.ServerTest do
  use ExUnit.Case
  doctest Dnrest

  require DNS.Records
  require Logger

  setup _context do
    DNS.Cache.clear()
    System.put_env("DEFAULT_DNS_SUFFIX", "example.test.io")
  end

  test "retrieve an :a record through dns" do
    DNS.Cache.set_record(:a, "me.com", "127.0.0.1")
    {:ok, record} = resolve("me.com", :a)
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - charlist" do
    DNS.Cache.set_record(:a, "me.com", to_charlist("127.0.0.1"))
    {:ok, record} = resolve("me.com", :a)
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - IPAddress" do
    address =
      case "127.0.0.1" |> DNS.IP_Utils.to_ipv4() do
        {:ok, address} ->
          address
      end

    DNS.Cache.set_record(:a, "me.com", address)
    {:ok, record} = resolve("me.com", :a)
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - tuple" do
    DNS.Cache.set_record(:a, "me.com", {127, 0, 0, 1})
    {:ok, record} = resolve("me.com", :a)
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - char" do
    DNS.Cache.set_record(:a, "me.com", fn -> "hello" end)
    {:error, :not_found} = resolve("me.com", :a)
  end

  test "retrieve an :srv record through dns" do
    DNS.Cache.set_record(:srv, "_test_srv._tcp.example.test.io.", {0, 0, 1000, 'my_host'})
    {:ok, record} = resolve("_test_srv._tcp.", :srv)
    assert record == [{0, 0, 1000, 'my_host'}]
  end

  test "retrieve an :srv record through dns no period" do
    DNS.Cache.set_record(:srv, "_test_srv._tcp.example.test.io.", {0, 0, 1000, 'my_host'})
    {:ok, record} = resolve("_test_srv._tcp", :srv)
    assert record == [{0, 0, 1000, 'my_host'}]
  end

  defp resolve(domain, type) do
    {:ok, socket} = :gen_udp.open(0, [:binary, active: false])

    {:ok, {_, _, data}} =
      try do
        {port, _} = System.get_env("DNS_PORT") |> Integer.parse()

        request =
          DNS.Records.dns_rec(
            header: DNS.Records.dns_header(),
            qdlist: [DNS.Records.dns_query(domain: domain |> to_charlist, type: type, class: :in)])

        :ok = :gen_udp.send(socket, '127.0.0.1', port, :inet_dns.encode(request))

        :gen_udp.recv(socket, 0, 5_000)
      after
        :ok = :gen_udp.close(socket)
      end

    {:ok, record} = :inet_dns.decode(data)

    answers = DNS.Records.to_map(record, :dns_rec).anlist

    cond do
      is_list(answers) and length(answers) > 0 ->
        output =
          answers
          |> Enum.map(&elem(&1, 6))
          |> Enum.reject(&is_nil/1)

        {:ok, output}

      true ->
        {:error, :not_found}
    end
  end
end
