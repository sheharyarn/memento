defmodule Memento.Support.Definitions do
  defmodule Tables do
    @moduledoc "Helper table definitions"

    defmodule User do
      use Memento.Table, attributes: [:id, :name]
    end


    defmodule Movie do
      alias __MODULE__
      use Memento.Table,
        type: :ordered_set,
        attributes: [:id, :title, :year, :director]


      def seed do
        movies = [
          %Movie{id: 1, title: "Reservoir Dogs",   year: 1992, director: "Quentin Tarantino"},
          %Movie{id: 2, title: "Rush",             year: 1991, director: "Lili Zanuck"},
          %Movie{id: 3, title: "Jurassic Park",    year: 1993, director: "Steven Spielberg"},
          %Movie{id: 4, title: "Kill Bill",        year: 2003, director: "Quentin Tarantino"},
          %Movie{id: 5, title: "Pulp Fiction",     year: 1994, director: "Quentin Tarantino"},
          %Movie{id: 6, title: "Rush",             year: 2013, director: "Ron Howard"},
          %Movie{id: 7, title: "Jaws",             year: 1975, director: "Steven Spielberg"},
          %Movie{id: 8, title: "Schindler's List", year: 1993, director: "Steven Spielberg"},
        ]

        Memento.Support.Mnesia.transaction(fn ->
          Enum.each(movies, &Memento.Query.write/1)
        end)
      end
    end

  end
end
