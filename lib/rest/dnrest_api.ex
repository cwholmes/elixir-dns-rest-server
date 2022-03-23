defmodule Rest.DnrestApi do
  use Maru.Server, otp_app: :restful_dns
end

defmodule Router.DNS do
  use Rest.DnrestApi

  require Logger

  namespace :dns do
    namespace :srv do
        params do
          # Allow records matching SRV standards https://en.wikipedia.org/wiki/SRV_record
          requires :entry, type: String, regexp: ~r/^_\w+(_\w+)*._(tcp|udp)(.\w+)*\.?$/
          requires :host, type: String
          requires :port, type: Integer
        end
        post do
          entry = params.entry |> DNS.Cache.canonicalize
          val = {0, 0, params.port, params.host |> DNS.Cache.canonicalize |> to_charlist}
          valString = "0 0 #{params.port} #{DNS.Cache.canonicalize(params.host)}"
          Logger.debug "Adding srv record [#{valString}] for entry [#{entry}]"
          DNS.Cache.set_record(:srv, to_string(entry), val)
          conn |> put_status(200) |> json(%{key: entry, record: valString})
        end
        params do
          # Allow records matching SRV standards https://en.wikipedia.org/wiki/SRV_record
          requires :entry, type: String, regexp: ~r/^_\w+(_\w+)*._(tcp|udp)(.\w+)*\.?$/
          optional :host, type: String
          optional :port, type: Integer
        end
        delete do
          entry = params.entry |> DNS.Cache.canonicalize |> to_string
          val_map = case params do
            %{host: host, port: port} -> %{host: DNS.Cache.canonicalize(host), port: port}
            %{host: host} -> %{host: DNS.Cache.canonicalize(host)}
            other -> other
          end
          Logger.debug "Request for delete: "
          Logger.debug fn() -> Enum.map_join(params, ", ", fn {key, val} -> ~s{#{key}: #{val}} end) end
          Logger.debug "Final delete params: "
          Logger.debug fn() -> Enum.map_join(val_map, ", ", fn {key, val} -> ~s{#{key}: #{val}} end) end
          case DNS.Cache.delete_srv_record(entry, val_map) do
            :ok ->
              conn |> put_status(204) |> text("No content")
            other ->
              conn |> put_status(500) |> text("Record could not be deleted.")
          end
        end
    end
    namespace :a do
      params do
        requires :host, type: String
        requires :ip_address, type: String, regexp: ~r/^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
      end
      post do
        case params.ip_address |> DNS.IP_Utils.to_ipv4 do
          {:ok, address} ->
            DNS.Cache.set_record(:a, params.host |> to_string |> DNS.Cache.canonicalize, address)
            conn |> put_status(200) |> json(%{key: DNS.Cache.canonicalize(params.host), record: to_string(:inet.ntoa(address))})
          {:error, _} ->
            conn |> put_status(400) |> text("Bad Request")
        end
      end
    end

    namespace :health do
      get do
        conn |> put_status(200) |> text("Everything's Okay!")
      end
    end
  end
end

defmodule Rest.API do
  use Rest.DnrestApi

  plug Plug.Parsers,
       pass: ["*/*"],
       json_decoder: Poison,
       parsers: [:urlencoded, :json, :multipart]

  mount Router.DNS

  rescue_from Unauthorized, as: e do
    IO.inspect(e)

    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

  rescue_from [MatchError, RuntimeError], with: :custom_error

  rescue_from :all, as: e do
    conn
    |> put_status(Plug.Exception.status(e))
    |> text("Server Error")
  end

  defp custom_error(conn, exception) do
    conn
    |> put_status(500)
    |> text(exception.message)
  end
end
