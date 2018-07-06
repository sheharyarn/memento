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
      app:          @app,
      version:      @version,
      elixir:       "~> 1.3",
      description:  description(),
      package:      package(),
      deps:         deps(),

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


  def application do
    [extra_applications: [:logger]]
  end


  defp deps do
    [
      {:amnesia, "~> 0.2.0"},
      {:ex_doc,  ">= 0.0.0", only: :dev},
    ]
  end


  defp description do
    "Mnesia Simplified"
  end


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

