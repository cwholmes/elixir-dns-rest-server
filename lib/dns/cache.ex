defmodule DNS.Cache do
  use GenServer

  @name DNSC

  require Logger

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: DNSC])
  end

  def set_record(type, key, val) do
    GenServer.cast(@name, {:write, type, key, val})
  end

  def get_record(type, key) do
    GenServer.call(@name, {:read, type, key})
  end

  def delete_record(type, key) do
    GenServer.cast(@name, {:delete, type, key})
  end

  def delete_srv_record(key, val_map) when is_map(val_map) do
    GenServer.cast(@name, {:delete, :srv, key, val_map})
  end

  def clear() do
    GenServer.cast(@name, {:clear})
  end

  def record_exists?(type, key) do
    GenServer.call(@name, {:exists?, type, key})
  end

  def canonicalize(key) when is_list(key) do
    key |> to_string |> canonicalize |> to_charlist
  end

  def canonicalize(key) when is_binary(key) do
    suffix = System.get_env("DEFAULT_DNS_SUFFIX")
    Logger.debug("Default dns suffix: #{suffix}")

    cond do
      Regex.match?(~r/^_\w+(_\w+)*._(tcp|udp)\.$/, key) ->
        key <> suffix <> "."

      Regex.match?(~r/^_\w+(_\w+)*._(tcp|udp)$/, key) ->
        key <> "." <> suffix <> "."

      Regex.match?(~r/^_\w+(_\w+)*._(tcp|udp)\.#{suffix}$/, key) ->
        key <> "."

      !String.contains?(key, ".") ->
        key <> "." <> suffix

      true ->
        key
    end
  end

  ## Server API

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:read, type, key}, _from, cache) do
    if Map.has_key?(cache, type) do
      {:reply, Map.get(Map.get(cache, type), key), cache}
    else
      {:reply, nil, cache}
    end
  end

  def handle_call({:exists?, type, key}, _from, cache) do
    if Map.has_key?(cache, type) do
      {:reply, Map.has_key?(Map.get(cache, type), key), cache}
    else
      {:reply, false, cache}
    end
  end

  def handle_cast({:write, :a, key, val}, cache) do
    if Map.has_key?(cache, :a) do
      inner = Map.put(Map.get(cache, :a), key, val)
      {:noreply, Map.put(cache, :a, inner)}
    else
      {:noreply, Map.put(cache, :a, %{key => val})}
    end
  end

  def handle_cast({:write, :srv, key, val}, cache) when is_tuple(val) do
    if tuple_size(val) == 4 && Map.has_key?(cache, :srv) do
      srvList = Map.get(cache, :srv)

      srvList =
        if Map.has_key?(srvList, key) do
          Map.put(srvList, key, Map.get(srvList, key) ++ [val])
        else
          Map.put(srvList, key, [val])
        end

      {:noreply, Map.put(cache, :srv, srvList)}
    else
      {:noreply, Map.put(cache, :srv, %{key => [val]})}
    end
  end

  def handle_cast({:delete, type, key}, cache) do
    if Map.has_key?(cache, type) do
      temp_type_map = Map.get(cache, type)
      temp_type_map = Map.delete(temp_type_map, key)
      {:noreply, Map.put(cache, type, temp_type_map)}
    else
      {:noreply, cache}
    end
  end

  def handle_cast({:delete, :srv, key, val_map}, cache) when is_map(val_map) do
    if Map.has_key?(cache, :srv) do
      temp_type_map = Map.get(cache, :srv)

      temp_val_list =
        case Map.get(temp_type_map, key) do
          nil -> []
          other -> other
        end

      temp_type_map =
        case Enum.filter(temp_val_list, filter_srv(val_map)) do
          # If the map ends up empty remove it.
          [] -> Map.delete(temp_type_map, key)
          other -> Map.put(temp_type_map, key, other)
        end

      {:noreply, Map.put(cache, :srv, temp_type_map)}
    else
      {:noreply, cache}
    end
  end

  def handle_cast({:delete, :srv, key, val_map}, cache) do
    # map was not valid so we don't delete anything
    {:noreply, cache}
  end

  def handle_cast({:clear}, _cache) do
    {:noreply, %{}}
  end

  defp filter_srv(%{host: host, port: port} = val_map) do
    fn val ->
      elem(val, 2) != port || !String.equivalent?(elem(val, 3), host)
    end
  end

  defp filter_srv(%{host: host} = val_map) do
    fn val ->
      !String.equivalent?(elem(val, 3), host)
    end
  end

  defp filter_srv(%{port: port} = val_map) do
    fn val ->
      elem(val, 2) != port
    end
  end

  defp filter_srv(val_map) do
    fn val ->
      # if no map is provided invalidate all
      false
    end
  end
end
