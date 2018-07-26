defmodule Memento.Support.Definitions do
  defmodule Tables do
    @moduledoc "Helper table definitions"

    defmodule User do
      alias __MODULE__
      use Memento.Table, attributes: [:id, :name]


      def seed do
        Memento.Support.Mnesia.transaction(fn ->
          1..10
          |> Enum.map(&%User{id: &1, name: "User #{&1}"})
          |> Enum.each(&Memento.Query.write/1)
        end)
      end
    end


    defmodule Movie do
      alias __MODULE__
      use Memento.Table,
        type: :ordered_set,
        attributes: [:id, :title, :year, :director]


      def seed do
        movies = [
          %Movie{id: 1,  title: "Reservoir Dogs",      year: 1992, director: "Quentin Tarantino"},
          %Movie{id: 2,  title: "Rush",                year: 1991, director: "Lili Zanuck"},
          %Movie{id: 3,  title: "Jurassic Park",       year: 1993, director: "Steven Spielberg"},
          %Movie{id: 4,  title: "Kill Bill",           year: 2003, director: "Quentin Tarantino"},
          %Movie{id: 5,  title: "Pulp Fiction",        year: 1994, director: "Quentin Tarantino"},
          %Movie{id: 6,  title: "Rush",                year: 2013, director: "Ron Howard"},
          %Movie{id: 7,  title: "Jaws",                year: 1975, director: "Steven Spielberg"},
          %Movie{id: 8,  title: "Schindler's List",    year: 1993, director: "Steven Spielberg"},
          %Movie{id: 9,  title: "Django Unchained",    year: 2012, director: "Quentin Tarantino"},
          %Movie{id: 10, title: "The Hateful Eight",   year: 2015, director: "Quentin Tarantino"},
          %Movie{id: 11, title: "Catch Me If You Can", year: 2008, director: "Steven Spielberg"},
          %Movie{id: 12, title: "The Post",            year: 2017, director: "Steven Spielberg"},
        ]

        Memento.Support.Mnesia.transaction(fn ->
          Enum.each(movies, &Memento.Query.write/1)
        end)
      end
    end

  end
end
