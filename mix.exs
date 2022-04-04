defmodule Dnrest.MixProject do
  use Mix.Project

  @version "0.1.0"
  @scm_url "https://github.com/cwholmes/elixir-dns-rest-server"
  @description """
    DNS server that contains a rest endpoint for A and SRV registration.
  """

  def project do
    [
      app: :elixir_dns_rest_server,
      name: "DNreSt",
      version: @version,
      elixir: "~> 1.13",
      description: @description,
      package: package(),
      deps: deps(),
      source_url: @scm_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Dnrest, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  # Run "mix deps.get" to download the deps for this project
  defp deps do
    [
      {:maru, "~> 0.13"},
      {:jason, "~> 1.1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:ranch, "~> 1.7.1"},
      {:cowboy, "~> 2.6.3"},
      {:poison, "~> 3.1"},
      {:distillery, "~> 2.1.1", runtime: false},
      {:dns, "~> 2.1.2", only: :test}
    ]
  end

  defp package do
    [
      name: "elixir-dns-rest-server",
      licenses: ["Apache-2.0"],
      maintainers: ["Cody Holmes"],
      links: %{GitHub: @scm_url}
    ]
  end
end
