import Config

config :elixir_dns_rest_server, Rest.DnrestApi,
  port: 0,
  ip: {127, 0, 0, 1}

config :elixir_dns_rest_server, DNS.DnrestServer, dns_port: 0
