defmodule Memento.Mixfile do
  use Mix.Project

  @app     :memento
  @name    "Memento"
  @version "0.5.0"
  @github  "https://github.com/sheharyarn/#{@app}"
  @author  "Sheharyar Naseer"
  @license "MIT"


  # NOTE:
  # To publish package or update docs, use the `docs`
  # mix environment to not include support modules
  # that are normally included in the `dev` environment
  #
  #   MIX_ENV=docs mix hex.publish
  #


  def project do
    [
      # Project
      app:           @app,
      version:       @version,
      elixir:        "~> 1.14",
      description:   description(),
      package:       package(),
      deps:          deps(),
      docs:          docs(),
      elixirc_paths: elixirc_paths(Mix.env),
      homepage_url:  @github,
    ]
  end


  # BEAM Application
  def application do
    [extra_applications: [:logger, :mnesia]]
  end


  # Dependencies
  defp deps do
    [
      {:ex_doc,  ">= 0.0.0", only: :docs},
      {:inch_ex, ">= 0.0.0", only: :docs},
    ]
  end


  # Compilation Paths
  defp elixirc_paths(:dev),  do: elixirc_paths(:test)
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:docs), do: ["lib"]
  defp elixirc_paths(_),     do: ["lib"]


  # Package Description
  defp description do
    "Simple & Powerful Elixir wrapper for the Mnesia Database"
  end


  # Package Information
  defp package do
    [
      name: @app,
      maintainers: [@author],
      licenses: [@license],
      files: ~w(mix.exs lib README.md CHANGELOG.md),
      links: %{"GitHub" => @github}
    ]
  end


  # ExDoc
  defp docs do
    [
      name: @name,
      main: "readme",
      source_url: @github,
      source_ref: "v#{@version}",
      canonical: "https://hexdocs.pm/#{@app}",
      extras: [
        {"README.md", title: @name},
        "CHANGELOG.md",
        "LICENSE"
      ],
      assets: %{
        "media" => "media"
      }
    ]
  end
end
