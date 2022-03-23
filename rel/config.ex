use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env

environment :dev do
  set dev_mode: true
  set include_erts: false
end

environment :debug do
  set include_erts: true
end

environment :prod do
  set include_erts: true
end

release :restful_dns do
  set version: current_version(:elixir_dns_server)
  set cookie: :elixir_dns_server
end
