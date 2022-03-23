# This config will be used for a dev environment.
# A dev environment is entered by executing command mix run --no-halt
# This command will run the configured apps with the following configurations.
# The app will halt when an exit is requested (Ctrl + C).
use Mix.Config

config :elixir_dns_server, Rest.DnrestApi,
  # modify this for you desired dev port
  port: 8000

config :elixir_dns_server, DNS.DnrestServer,
  # modify this for you desired dev port
  dns_port: 53
