defmodule DNS.CacheTest do
  use ExUnit.Case
  doctest Dnrest

  setup _context do
    DNS.Cache.clear()
    System.put_env("DEFAULT_DNS_SUFFIX", "example.test.io")
  end

  test "put a record in cache" do
    {:ok, ip} = :inet.parse_ipv4_address('127.0.0.1')
    DNS.Cache.set_record(:a, "google.com", ip)
    assert DNS.Cache.get_record(:a, "google.com") == {127, 0, 0, 1}
  end

  test "retrieval of non existent a record returns nil" do
    assert DNS.Cache.get_record(:a, "example.io") == nil
  end

  test "put srv record in cache" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [{0, 0, 1000, "test"}]
  end

  test "retrieval of non existent srv record returns nil" do
    assert DNS.Cache.get_record(:srv, "_test_srv2._tcp") == nil
  end

  test "delete an srv record" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    assert DNS.Cache.delete_record(:srv, "_test_srv1._tcp") == :ok
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == nil
  end

  test "delete non-existant srv record" do
    assert DNS.Cache.delete_record(:srv, "_test_srv1._tcp") == :ok
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == nil
  end

  test "delete an srv record does not delete all records" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv2._tcp", {0, 0, 1000, "test"})
    assert DNS.Cache.delete_record(:srv, "_test_srv1._tcp") == :ok
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == nil
    assert DNS.Cache.get_record(:srv, "_test_srv2._tcp") != nil
  end

  test "delete non-existant srv record does not delete all records" do
    DNS.Cache.set_record(:srv, "_test_srv2._tcp", {0, 0, 1000, "test"})
    assert DNS.Cache.delete_record(:srv, "_test_srv1._tcp") == :ok
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == nil
    assert DNS.Cache.get_record(:srv, "_test_srv2._tcp") != nil
  end

  test "delete single srv record same host" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test2"})
    assert DNS.Cache.delete_srv_record("_test_srv1._tcp", %{host: "test"}) == :ok
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [{0, 0, 1000, "test2"}]
  end

  test "delete single srv record same port" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 2000, "test"})
    assert DNS.Cache.delete_srv_record("_test_srv1._tcp", %{port: 1000}) == :ok
    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [{0, 0, 2000, "test"}]
  end

  test "delete single srv record same host and port" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 2000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test2"})
    assert DNS.Cache.delete_srv_record("_test_srv1._tcp", %{host: "test", port: 1000}) == :ok

    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [
             {0, 0, 2000, "test"},
             {0, 0, 1000, "test2"}
           ]
  end

  test "delete single srv record same host and port extra map entry" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 2000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test2"})

    assert DNS.Cache.delete_srv_record("_test_srv1._tcp", %{host: "test", port: 1000, other: 1}) ==
             :ok

    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [
             {0, 0, 2000, "test"},
             {0, 0, 1000, "test2"}
           ]
  end

  test "delete single srv record char string (host charlist)" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 2000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test2"})

    assert DNS.Cache.delete_srv_record("_test_srv1._tcp", %{host: 'test', port: 1000, other: 1}) ==
             :ok

    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [
             {0, 0, 2000, "test"},
             {0, 0, 1000, "test2"}
           ]
  end

  test "delete single srv record char string (host string)" do
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 2000, "test"})
    DNS.Cache.set_record(:srv, "_test_srv1._tcp", {0, 0, 1000, "test2"})

    assert DNS.Cache.delete_srv_record("_test_srv1._tcp", %{host: "test", port: 1000, other: 1}) ==
             :ok

    assert DNS.Cache.get_record(:srv, "_test_srv1._tcp") == [
             {0, 0, 2000, "test"},
             {0, 0, 1000, "test2"}
           ]
  end

  test "Canonicalize simple no period" do
    assert DNS.Cache.canonicalize("_test_srv._tcp") == "_test_srv._tcp.example.test.io."
  end

  test "Canonicalize simple with period" do
    assert DNS.Cache.canonicalize("_test_srv._tcp.") == "_test_srv._tcp.example.test.io."
  end

  test "Canonicalize canonical no period" do
    assert DNS.Cache.canonicalize("_test_srv._tcp.example.test.io") ==
             "_test_srv._tcp.example.test.io."
  end

  test "Canonicalize canonical with period" do
    assert DNS.Cache.canonicalize("_test_srv._tcp.example.test.io.") ==
             "_test_srv._tcp.example.test.io."
  end

  test "Canonicalize other canonical no period" do
    assert DNS.Cache.canonicalize("_test_srv._tcp.example.io") == "_test_srv._tcp.example.io"
  end

  test "Canonicalize other canonical with period" do
    assert DNS.Cache.canonicalize("_test_srv._tcp.example.io.") == "_test_srv._tcp.example.io."
  end

  test "Canonicalize binary simple" do
    assert DNS.Cache.canonicalize('_test_srv._tcp') == '_test_srv._tcp.example.test.io.'
  end

  test "Canonicalize string host canonical" do
    assert DNS.Cache.canonicalize("host_name.com") == "host_name.com"
  end

  test "Canonicalize string host simple" do
    assert DNS.Cache.canonicalize("host_name") == "host_name.example.test.io"
  end

  test "Canonicalize binary host canonical" do
    assert DNS.Cache.canonicalize('host_name.com') == 'host_name.com'
  end

  test "Canonicalize binary host simple" do
    assert DNS.Cache.canonicalize('host_name') == 'host_name.example.test.io'
  end
end
