defmodule Memento.Mixfile do
  use Mix.Project

  @app     :memento
  @name    "Memento"
  @version "0.0.1"
  @github  "https://github.com/sheharyarn/#{@app}"
  @author  "Sheharyar Naseer"
  @license "MIT"


  def project do
    [
      # Project
      app:           @app,
      version:       @version,
      elixir:        "~> 1.3",
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
    [extra_applications: [:logger]]
  end


  # Dependencies
  defp deps do
    [
      {:amnesia, "~> 0.2.0"},
      {:ex_doc,  "~> 0.18.0", only: :dev},
    ]
  end


  # Compilation Paths
  defp elixirc_paths(:dev),  do: elixirc_paths(:test)
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]


  # Package Description
  defp description do
    "Mnesia Simplified"
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

