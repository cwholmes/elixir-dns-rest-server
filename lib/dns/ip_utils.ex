defmodule DNS.IP_Utils do

  def to_ipv4(ip) when is_list(ip) do
    :inet.parse_ipv4_address(ip)
  end

  def to_ipv4(ip) when is_binary(ip) do
    ip |> to_charlist |> :inet.parse_ipv4_address
  end

  def to_ipv4(ip) when is_tuple(ip) do
    ip |> :inet.ntoa |> :inet.parse_ipv4_address
  end

  def to_ipv4(ip) do
    {:error, "incompatible type"}
  end
end
