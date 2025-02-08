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


    defmodule Email do
      alias __MODULE__
      use Memento.Table,
        type: :bag,
        attributes: [:user_id, :email]

      def seed do
        emails = [
          %Email{user_id: 1, email: "user.1@gmail.com"},
          %Email{user_id: 1, email: "user.1@outlook.com"},
          %Email{user_id: 2, email: "user.2@outlook.com"},
          %Email{user_id: 2, email: "user.2@gmail.com"},
          %Email{user_id: 2, email: "user.2@example.com"},
          %Email{user_id: 3, email: "user.3@gmail.com"},
        ]

        Memento.Support.Mnesia.transaction(fn ->
          Enum.each(emails, &Memento.Query.write/1)
        end)
      end
    end


    defmodule Movie do
      alias __MODULE__
      use Memento.Table,
        type: :ordered_set,
        autoincrement: true,
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


    defmodule Nested do
      alias __MODULE__
      use Memento.Table,
        type: :ordered_set,
        autoincrement: true,
        attributes: [:id, :data]

      def seed do
        nested = [
          %Nested{id: 1, data: %{title: "Elixir",  type: :language,  stars: 15000}},
          %Nested{id: 2, data: %{title: "Phoenix", type: :framework, stars: 13000}},
          %Nested{id: 3, data: %{title: "Memento", type: :library,   stars: 160}},
          %Nested{id: 4, data: %{title: "Ecto",    type: :library,   stars: 4000}},
          %Nested{id: 5, data: %{title: "Ruby",    type: :language,  stars: 16000}},
        ]

        Memento.Support.Mnesia.transaction(fn ->
          Enum.each(nested, &Memento.Query.write/1)
        end)
      end
    end

  end
end
