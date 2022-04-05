defmodule DNS.Records do
  require Record
  require Logger

  Record.defrecord(
    :dns_header,
    Record.extract(:dns_header, from_lib: "kernel/src/inet_dns.hrl")
  )

  Record.defrecord(
    :dns_rec,
    Record.extract(:dns_rec, from_lib: "kernel/src/inet_dns.hrl")
  )

  Record.defrecord(:dns_rr, Record.extract(:dns_rr, from_lib: "kernel/src/inet_dns.hrl"))

  Record.defrecord(
    :dns_query,
    Record.extract(:dns_query, from_lib: "kernel/src/inet_dns.hrl")
  )

  defmacro to_record(map, type) do
    fields = Record.extract(type, from_lib: "kernel/src/inet_dns.hrl")

    normalizer_fun = fn
      {key, _} when is_atom(key) ->
        key

      key when is_atom(key) ->
        key
    end

    keys = :lists.map(normalizer_fun, fields)
    IO.puts("keys = #{inspect(keys)}")

    quote do
      [unquote(type) | [unquote_splicing(keys)] |> Enum.map(&Map.get(unquote(map), &1))]
      |> List.to_tuple()
    end
  end

  defmacro to_map(record) do
    to_map_quote(record, nil)
  end

  defmacro to_map(record, type) do
    case type do
      :dns_header -> quote do: unquote(record) |> DNS.Records.dns_header() |> Enum.into(%{})
      :dns_rec -> quote do: unquote(record) |> DNS.Records.dns_rec() |> Enum.into(%{})
      :dns_rr -> quote do: unquote(record) |> DNS.Records.dns_rr() |> Enum.into(%{})
      :dns_query -> quote do: unquote(record) |> DNS.Records.dns_query() |> Enum.into(%{})
      _ -> to_map_quote(record, type)
    end
  end

  defp to_map_quote(record, type) do
    quote do
      rec_type =
        case unquote(type) do
          nil -> unquote(record) |> elem(0)
          _ -> unquote(type)
        end

      Logger.debug("To map type = #{rec_type} record = #{inspect(unquote(record))}")

      case rec_type do
        :dns_header -> unquote(record) |> DNS.Records.dns_header() |> Enum.into(%{})
        :dns_rec -> unquote(record) |> DNS.Records.dns_rec() |> Enum.into(%{})
        :dns_rr -> unquote(record) |> DNS.Records.dns_rr() |> Enum.into(%{})
        :dns_query -> unquote(record) |> DNS.Records.dns_query() |> Enum.into(%{})
      end
    end
  end
end
