defmodule Memento.Mixfile do
  use Mix.Project

  @app     :memento
  @name    "Memento"
  @version "0.3.1"
  @github  "https://github.com/sheharyarn/#{@app}"
  @author  "Sheharyar Naseer"
  @license "MIT"


  # NOTE:
  # To publish package or update docs, use the `docs`
  # mix environment to not include support modules
  # that are normally included in the `dev` environment
  #
  #   MIX_ENV=docs hex.publish
  #


  def project do
    [
      # Project
      app:           @app,
      version:       @version,
      elixir:        "~> 1.7",
      description:   description(),
      package:       package(),
      deps:          deps(),
      elixirc_paths: elixirc_paths(Mix.env),

      # ExDoc
      name:         @name,
      source_url:   @github,
      homepage_url: @github,
      docs: [
        main:       @name,
        canonical:  "https://hexdocs.pm/#{@app}",
        extras:     ["README.md"]
      ]
    ]
  end


  # BEAM Application
  def application do
    [extra_applications: [:logger, :mnesia]]
  end


  # Dependencies
  defp deps do
    [
      {:ex_unit_clustered_case, "~> 0.4",   only: :test},
      {:ex_doc,                 ">= 0.0.0", only: :docs},
      {:inch_ex,                ">= 0.0.0", only: :docs},
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
      files: ~w(mix.exs lib README.md),
      links: %{"Github" => @github}
    ]
  end

end
