defmodule DNS.ServerTest do
  use ExUnit.Case
  doctest Dnrest

  setup _context do
    DNS.Cache.clear()
    System.put_env("DEFAULT_DNS_SUFFIX", "example.test.io")
  end

  test "retrieve an :a record through dns" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()
    DNS.Cache.set_record(:a, "me.com", "127.0.0.1")
    {:ok, record} = DNS.resolve("me.com", :a, {"127.0.0.1", port})
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - charlist" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()
    DNS.Cache.set_record(:a, "me.com", to_charlist("127.0.0.1"))
    {:ok, record} = DNS.resolve("me.com", :a, {"127.0.0.1", port})
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - IPAddress" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()

    address =
      case "127.0.0.1" |> DNS.IP_Utils.to_ipv4() do
        {:ok, address} ->
          address
      end

    DNS.Cache.set_record(:a, "me.com", address)
    {:ok, record} = DNS.resolve("me.com", :a, {"127.0.0.1", port})
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - tuple" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()
    DNS.Cache.set_record(:a, "me.com", {127, 0, 0, 1})
    {:ok, record} = DNS.resolve("me.com", :a, {"127.0.0.1", port})
    assert record == [{127, 0, 0, 1}]
  end

  test "retrieve an :a record through dns - char" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()
    DNS.Cache.set_record(:a, "me.com", fn -> "hello" end)
    {:error, :not_found} = DNS.resolve("me.com", :a, {"127.0.0.1", port})
  end

  test "retrieve an :srv record through dns" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()
    DNS.Cache.set_record(:srv, "_test_srv._tcp.example.test.io.", {0, 0, 1000, 'my_host'})
    {:ok, record} = DNS.resolve("_test_srv._tcp.", :srv, {"127.0.0.1", port})
    assert record == [{0, 0, 1000, 'my_host'}]
  end

  test "retrieve an :srv record through dns no period" do
    {port, _} = System.get_env("DNS_PORT") |> Integer.parse()
    DNS.Cache.set_record(:srv, "_test_srv._tcp.example.test.io.", {0, 0, 1000, 'my_host'})
    {:ok, record} = DNS.resolve("_test_srv._tcp", :srv, {"127.0.0.1", port})
    assert record == [{0, 0, 1000, 'my_host'}]
  end
end
