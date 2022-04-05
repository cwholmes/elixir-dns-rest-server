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
    keys = get_keys_with_defaults(type)

    # build a keyword from the map given to call the record macro
    keyword_from_map =
      Enum.map(keys, fn {key, value} ->
        quote(do: {unquote(key), Map.get(unquote(map), unquote(key), unquote(value))})
      end)

    quote do
      DNS.Records.unquote(type)([unquote_splicing(keyword_from_map)])
    end
  end

  defmacro to_map(record, type) do
    if Keyword.keyword?(record) do
      quote(do: unquote(record) |> Enum.into(%{}))
    else
      quote do
        DNS.Records.unquote(type)(unquote(record)) |> Enum.into(%{})
      end
    end
  end

  defp get_keys_with_defaults(type) do
    normalizer_fun = fn
      {key, value} when is_atom(key) ->
        {key, value}

      key when is_atom(key) ->
        {key, nil}
    end

    get_record_fields(type, normalizer_fun)
  end

  defp get_record_fields(type, normalizer_fun) do
    fields = Record.extract(type, from_lib: "kernel/src/inet_dns.hrl")

    :lists.map(normalizer_fun, fields)
  end
end
