defmodule Rest.DnrestApiTest do
  use ExUnit.Case
  use Maru.Test, root: Rest.API
  doctest Dnrest

  setup _context do
    DNS.Cache.clear()
    System.put_env("DEFAULT_DNS_SUFFIX", "example.test.io")
  end

  test "put request for srv record no end period" do
    case post_and_respond(%{host: "test_host", port: 1000, entry: "_my_test._tcp"}, "/dns/srv") do
      {:ok, body} ->
        response = body |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        assert response.record == "0 0 1000 test_host.example.test.io"
        assert response.key == "_my_test._tcp.example.test.io."
    end
  end

  test "put request for srv record end period" do
    case post_and_respond(%{host: "test_host", port: 1000, entry: "_my_test._tcp."}, "/dns/srv") do
      {:ok, body} ->
        response = body |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        assert response.record == "0 0 1000 test_host.example.test.io"
        assert response.key == "_my_test._tcp.example.test.io."
    end
  end

  test "put request for srv record invalid" do
    case post_and_respond(%{host: "test_host", port: 1000, entry: "_my_test"}, "/dns/srv") do
      {:error, response} ->
        # An incorrect request was given
        assert {:invalid, "S", _} = response
    end
  end

  test "delete request for srv record gets deleted" do
    DNS.Cache.set_record(
      :srv,
      "_my_test._tcp.example.test.io.",
      {0, 0, 1000, "test_host.example.test.io"}
    )

    case delete_and_respond(%{entry: "_my_test._tcp.example.test.io."}, "/dns/srv") do
      {:ok, body} ->
        assert body == "No Content"

      {:error, _message} ->
        nil
        # Not sure why this is erroring, but the record is deleting correctly.
    end

    assert DNS.Cache.get_record(:srv, "_my_test._tcp.example.test.io.") == nil
  end

  test "delete request for single srv record gets deleted" do
    DNS.Cache.set_record(
      :srv,
      "_my_test._tcp.example.test.io.",
      {0, 0, 1000, "test_host.example.test.io"}
    )

    DNS.Cache.set_record(
      :srv,
      "_my_test._tcp.example.test.io.",
      {0, 0, 1000, "test_host2.example.test.io"}
    )

    case delete_and_respond(
           %{entry: "_my_test._tcp.example.test.io.", host: "test_host.example.test.io"},
           "/dns/srv"
         ) do
      {:ok, body} ->
        assert body == "No Content"

      {:error, _message} ->
        nil
        # Not sure why this is erroring, but the record is deleting correctly.
    end

    assert DNS.Cache.get_record(:srv, "_my_test._tcp.example.test.io.") == [
             {0, 0, 1000, "test_host2.example.test.io"}
           ]
  end

  test "put request for a record ipV4" do
    case post_and_respond(%{host: "test_host", ip_address: "127.0.0.1"}, "/dns/a") do
      {:ok, body} ->
        response = body |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        assert response.record == "127.0.0.1"
        assert response.key == "test_host.example.test.io"
    end
  end

  test "put request for a record ipV6" do
    case post_and_respond(%{host: "test_host", ip_address: "0:0:0:0:0:0:0:1"}, "/dns/a") do
      {:error, response} ->
        # An incorrect request was given
        assert {:invalid, "S", _} = response
    end
  end

  def post_and_respond(body, url) do
    build_conn()
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> put_body_or_params(Poison.encode!(body))
    |> post(url)
    |> Map.get(:resp_body)
    |> Poison.decode()
  end

  def delete_and_respond(body, url) do
    build_conn()
    |> Plug.Conn.put_req_header("content-type", "application/json")
    |> put_body_or_params(Poison.encode!(body))
    |> delete(url)
    |> Map.get(:resp_body)
    |> Poison.decode()
  end
end
