defmodule Dnrest.MixProject do
  use Mix.Project

  @version "0.1.0"
  @scm_url "https://github.com/cwholmes/elixir-dns-server"
  @description """
    DNS server that contains a rest endpoint for A and SRV registration.
  """

  def project do
    [
      app: :elixir_dns_server,
      name: "DNreSt",
      version: @version,
      elixir: "~> 1.8",
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
      {:dns, "~> 2.1.2"},
      {:maru, "~> 0.13"},
      {:jason, "~> 1.1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:ranch, "~> 1.7.1"},
      {:cowboy, "~> 2.6.3"},
      {:distillery, "~> 1.5.2", runtime: false},
      {:poison, "~> 3.1"}
    ]
  end

  defp package do
    [
      name: "elixir-dns-server",
      licenses: ["Apache-2.0"],
      maintainers: ["Cody Holmes"],
      links: %{GitHub: @scm_url}
    ]
  end
end
