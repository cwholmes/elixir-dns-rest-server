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
    keys = get_keys(type)

    quote do
      [unquote(type) | [unquote_splicing(keys)] |> Enum.map(&Map.get(unquote(map), &1))]
      |> List.to_tuple()
    end
  end

  defmacro to_map(record, type) do
    keys = get_keys(type)

    quote do
      [_tag | values] = Tuple.to_list(unquote(record))
      Enum.zip([unquote_splicing(keys)], values) |> Enum.into(%{})
    end
  end

  defp get_keys(type) do
    fields = Record.extract(type, from_lib: "kernel/src/inet_dns.hrl")

    normalizer_fun = fn
      {key, _} when is_atom(key) ->
        key

      key when is_atom(key) ->
        key
    end

    :lists.map(normalizer_fun, fields)
  end
end
