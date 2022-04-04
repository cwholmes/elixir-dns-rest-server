import Config

config :elixir_dns_rest_server, Rest.DnrestApi,
  # modify this for you desired dev port
  port: 8080

config :elixir_dns_rest_server, DNS.DnrestServer,
  # modify this for you desired dev port
  dns_port: 53

config :logger, level: :debug
