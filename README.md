<!-- Heading: Start -->
<h1 align="center">
  <a href="https://hexdocs.pm/memento">
    <img alt="Memento" src='media/logo.png' width='400px'/>
  </a>
</h1>

<p align="center">
  <a href="https://travis-ci.org/sheharyarn/memento">
    <img alt="Build Status" src="https://img.shields.io/travis/sheharyarn/memento/master.svg" />
  </a>
  <a href="https://hexdocs.pm/memento">
    <img alt="Coverage" src="https://inch-ci.org/github/sheharyarn/memento.svg?branch=master" />
  </a>
  <a href="https://hex.pm/packages/memento">
    <img alt="Version" src="https://img.shields.io/hexpm/v/memento.svg" />
  </a>
  <a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/hexpm/l/memento.svg" />
  </a>
</p>

<p align="center">
  <b>Simple but Powerful Elixir interface to the Erlang Mnesia Database</b></br>
  <sub>Mnesia. Memento. <a href="https://www.imdb.com/title/tt0209144/">Get it?</a><sub>
</p>

<br/>
<!-- Heading: End -->



 - **Easy to Use:** Provides a simple & intuitive API for working with [Mnesia][mnesia]
 - **Real-time:** Has extremely fast real-time data searches, even across many nodes
 - **Powerful Queries:** on top of Erlang's MatchSpec and QLC, that are much easier to use
 - **Detailed Documentation:** and examples for all methods on [Hexdocs.pm][docs]
 - **Persistent:** Schema can be coherently kept on disc & in memory
 - **Distributed:** Data can easily be replicated on several nodes
 - **Atomic:** A series of operations can be grouped in to a single atomic transaction
 - **Focused:** Encourages good patterns by omitting dirty calls to the database
 - **Mnesia Compatible:** You can still use Mnesia methods for Schemas and Tables created by Memento
 - **No Dependencies:** Zero external dependencies; only uses the built-in Mnesia module
 - **MIT Licensed**: Free for personal and commercial use

<br/>



**Memento** is an extremely easy-to-use and powerful wrapper in Elixir that makes is intuitive to work with
[Mnesia][mnesia], the Erlang Distributed Realtime Database. The original Mnesia API in Erlang is convoluted, unorganized
and combined with the complex `MatchSpec` and `QLC` query language, is hard to work with in Elixir, especially for
beginners. Memento attempts to define a simple API to work with tables, removing the majority of complexity associated
with it.

<br/>




## Installation

Add `memento` to your list of dependencies in your Mix file:

```elixir
def deps do
  [{:memento, "~> 0.0.1"}]
end
```

If your Elixir version is `1.3` or lower, also add it to your `applications` list:

```elixir
def application do
  [applications: [:memento]]
end
```

_It's preferable to only add `:memento` and not `:mnesia` along with it._ This will ensure that that OTP calls to Mnesia
go through the Supervisor spec specified in Memento.

<br/>




## Configuration

It is highly recommended that a custom path to the Mnesia database location is specified, even on the local `:dev`
environment (You can add `.mnesia` to your `.gitignore`):

```elixir
# config/config.exs
config :mnesia,
  dir: '.mnesia/#{Mix.env}/#{node()}'        # Notice the single quotes
```

<br/>




## Usage

You start by defining a specific Module as a Memento Table by specifying its attributes, type and other options. A simple
definition looks like this:

```elixir
defmodule Blog.Author do
  use Memento.Table, attributes: [:id, :name]
end
```

A slightly more complex definition that uses more options, could look like this:

```elixir
defmodule Blog.Post do
  use Memento.Table,
    attributes: [:id, :title, :content, :status, :author_id],
    index: [:status, :author_id],
    type: :ordered_set


  # You can also define other methods
  # or helper functions in the module
end
```

Once you have defined your schemas, you need to create them before you can interact with them:

```elixir
Memento.Table.create(Blog.Author)
Memento.Table.create(Blog.Post)
```

See the [`Memento.Table`][docs-table] documentation for detailed examples and more information about all the options.

<br/>




## CRUD Operations & Queries

Once a Table has been created, you can perform read/write/delete operations on their records. An API for all of
these operations is exposed in the [`Memento.Query`][docs-query] module, but these methods can't be called directly.
Instead, they must always be called inside a [`Memento.Transaction`][docs-transaction]:

```elixir
Memento.transaction! fn ->
  Memento.Query.all(Blog.Author)
end

# => [
#  %Blog.Author{id: 1, name: "Alice"},
#  %Blog.Author{id: 2, name: "Bob"},
#  %Blog.Author{id: 3, name: "Eve"},
# ]
```

For the sake of succinctness, transactions are ignored in most of the examples below, but they are still required.
Here's a quick overview of all the basic operations:


```elixir
# Get all records in a Table
Memento.Query.all(Author)

# Get a specific record by its primary key
Memento.Query.read(Author, id)

# Write a record
Memento.Query.write(%Author{id: 3, name: "Some Author"})

# Delete a record by primary key
Memento.Query.delete(Author, id)

# Delete a record by passing the full object
Memento.Query.delete_record(%Author{id: 4, name: "Another Author"})
```


For more complex read operations, Memento exposes a [`select/3`][docs-query-select] method that lets you chain
conditions using a simplified version of the Erlang MatchSpec. This what some queries would look like for a
`Movie` table:

 - Get all Movies named "Rush"

    ```elixir
    Memento.Query.select(Movie, {:==, :title, "Rush"})
    ```


 - Get all Movies directed by Tarantino before the year 2000

    ```elixir
    guards = [
      {:==, :director, "Quentin Tarantino"},
      {:<, :year, 2000},
    ]
    Memento.Query.select(Movie, guards)
    ```

See [`Query.select/3`][docs-query-select] for more information about the guard operators and detailed examples.

<br/>




## Roadmap

 - [x] Memento
    - [x] start/stop
    - [x] info
    - [x] system_info
    - [ ] Application
    - [ ] Config Vars
 - [x] Memento.Table
    - [x] Create/Delete helpers
    - [x] clear_table
    - [x] table_info
    - [ ] wait
    - [ ] Ecto-like DSL
    - [ ] Migration Support
 - [x] Memento.Query
    - [x] Integration with Memento.Table
    - [x] match/select
    - [x] read/write/delete
    - [ ] first/next/prev/all_keys
    - [ ] test matchspec
    - [ ] continue/1 for select continuations
    - [ ] autoincrement
    - [ ] Helper use macro
 - [x] Memento.Transaction
    - [x] Simple/Synchronous
    - [x] Bang versions
    - [x] inside?
    - [x] abort
    - [ ] Lock Helpers
 - [x] Memento.Schema
    - [x] create/delete
    - [x] print (schema/1)
 - [ ] Memento.Collection
    - [ ] Easy Helpers
    - [ ] Custom DSL
  - [ ] Mix Tasks

<br/>




## Contributing

 - [Fork][github-fork], Enhance, Send PR
 - Lock issues with any bugs or feature requests
 - Implement something from Roadmap
 - Spread the word :heart:

<br>




## License

This package is available as open source under the terms of the [MIT License][license].

<br>





  [logo]:                 media/logo.png
  [shield-version]:       https://img.shields.io/hexpm/v/memento.svg
  [shield-license]:       https://img.shields.io/hexpm/l/memento.svg
  [shield-downloads]:     https://img.shields.io/hexpm/dt/memento.svg
  [shield-travis]:        https://img.shields.io/travis/sheharyarn/memento/master.svg
  [shield-inch]:          https://inch-ci.org/github/sheharyarn/memento.svg?branch=master

  [travis-ci]:            https://travis-ci.org/sheharyarn/memento
  [inch-ci]:              https://inch-ci.org/github/sheharyarn/memento

  [license]:              ./LICENSE
  [mnesia]:               http://erlang.org/doc/man/mnesia.html
  [hexpm]:                https://hex.pm/packages/memento
  [imdb-memento]:         https://www.imdb.com/title/tt0209144/
  [que]:                  https://github.com/sheharyarn/que

  [docs]:                 https://hexdocs.pm/memento
  [docs-transaction]:     https://hexdocs.pm/memento/Memento.Transaction.html
  [docs-table]:           https://hexdocs.pm/memento/Memento.Table.html
  [docs-query]:           https://hexdocs.pm/memento/Memento.Query.html
  [docs-query-select]:    https://hexdocs.pm/memento/Memento.Query.html#select/3

  [github-fork]:          https://github.com/sheharyarn/memento/fork
