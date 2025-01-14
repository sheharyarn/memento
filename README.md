<!-- Heading: Start -->
<div align="center">
  <a href="https://hexdocs.pm/memento">
    <img alt="Memento" src="media/logo.png" width="450px"/>
  </a>
</div>


<p align="center">
  <a href="https://github.com/sheharyarn/memento/actions/workflows/ci.yml">
    <img alt="CI Status" src="https://github.com/sheharyarn/memento/actions/workflows/ci.yml/badge.svg" />
  </a>
  <a href="https://hexdocs.pm/memento">
    <img alt="Coverage" src="https://inch-ci.org/github/sheharyarn/memento.svg?branch=master" />
  </a>
  <a href="https://hex.pm/packages/memento">
    <img alt="Version" src="https://img.shields.io/hexpm/v/memento.svg" />
  </a>
  <a href="https://hex.pm/packages/memento">
    <img alt="Version" src="https://img.shields.io/hexpm/dt/memento.svg" />
  </a>
  <a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/hexpm/l/memento.svg" />
  </a>
</p>

<p align="center">
  <b>Simple but Powerful Elixir interface to the Erlang Mnesia Database</b></br>
  <sub>Mnesia. Memento. <a href="https://www.imdb.com/title/tt0209144/">Get it?</a></sub>
</p>

<br/>
<!-- Heading: End -->



 - 😀 **Easy to Use:** Provides a simple & intuitive API for working with [Mnesia][mnesia]
 - ⚡️ **Real-time:** Has extremely fast real-time data searches, even across many nodes
 - 💪 **Powerful Queries:** on top of Erlang's MatchSpec and QLC, that are much easier to use
 - 📓 **Detailed Documentation:** and examples for all methods on [HexDocs][docs]
 - 💾 **Persistent:** Schema can be coherently kept on disc & in memory
 - 🌐 **Distributed:** Data can easily be replicated on several nodes
 - 🌀 **Atomic:** A series of operations can be grouped in to a single atomic transaction
 - 🔍 **Focused:** Encourages good patterns by omitting dirty calls to the database
 - 🔧 **Mnesia Compatible:** You can still use Mnesia methods for Schemas and Tables created by Memento
 - ❄️  **No Dependencies:** Zero external dependencies; only uses the built-in Mnesia module
 - ⛅️ **MIT Licensed**: Free for personal and commercial use

<br/>



**Memento** is an extremely easy-to-use and powerful wrapper in Elixir that makes it intuitive to work with
[Mnesia][mnesia], the Erlang Distributed Realtime Database. The original Mnesia API in Erlang is convoluted, unorganized
and combined with the complex `MatchSpec` and `QLC` query language, is hard to work with in Elixir, especially for
beginners. Memento attempts to define a simple API to work with schemas, removing the majority of complexity associated
with it.

<br/>




## Installation

Add `:memento` to your list of dependencies in your Mix file:

```elixir
def deps do
  [{:memento, "~> 0.5.0"}]
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

You start by defining a Module as a Memento Table by specifying its attributes, type and other options. At least two
attributes are required, where the first one is the `primary-key` of the table. A simple definition looks like this:

```elixir
defmodule Blog.Author do
  use Memento.Table, attributes: [:username, :fullname]
end
```

A slightly more complex definition that uses more options, could look like this:

```elixir
defmodule Blog.Post do
  use Memento.Table,
    attributes: [:id, :title, :content, :status, :author],
    index: [:status, :author],
    type: :ordered_set,
    autoincrement: true


  # You can also define other methods
  # or helper functions in the module
end
```

Once you have defined your schemas, you need to create them before you can interact with them:

```elixir
Memento.Table.create!(Blog.Author)
Memento.Table.create!(Blog.Post)
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
#  %Blog.Author{username: :sye,     fullname: "Sheharyar Naseer"},
#  %Blog.Author{username: :jeanne,  fullname: "Jeanne Bolding"},
#  %Blog.Author{username: :pshore,  fullname: "Paul Shore"},
# ]
```

_For the sake of succinctness, transactions are ignored in most of the examples below, but they are still required._
Here's a quick overview of all the basic operations:


```elixir
# Get all records in a Table
Memento.Query.all(Post)

# Get a specific record by its primary key
Memento.Query.read(Post, id)
Memento.Query.read(Author, username)

# Write a record
Memento.Query.write(%Author{username: :sarah, name: "Sarah Molton"})

# Delete a record by primary key
Memento.Query.delete(Post, id)
Memento.Query.delete(Author, username)

# Delete a record by passing the full object
Memento.Query.delete_record(%Author{username: :pshore, name: "Paul Shore"})
```


For more complex read operations, Memento exposes a [`select/3`][docs-query-select] method that lets you chain
conditions using a simplified version of the Erlang MatchSpec. This is what some queries would look like for a
`Movie` table:

 - Get all movies named "Rush":

    ```elixir
    Memento.Query.select(Movie, {:==, :title, "Rush"})
    ```


 - Get all movies directed by Tarantino before the year 2000:

    ```elixir
    guards = [
      {:==, :director, "Quentin Tarantino"},
      {:<, :year, 2000},
    ]
    Memento.Query.select(Movie, guards)
    ```

See [`Query.select/3`][docs-query-select] for more information about the guard operators and detailed examples.

<br/>




## Persisting to Disk

Setting up disk persistence in `Mnesia` has always been a bit weird. It involves stopping the application, creating
schemas on disk, restarting the application and then creating the tables with certain options. Here are the steps
you need to take to do all of that:

```elixir
# List of nodes where you want to persist
nodes = [ node() ]

# Create the schema
Memento.stop
Memento.Schema.create(nodes)
Memento.start

# Create your tables with disc_copies (only the ones you want persisted on disk)
Memento.Table.create!(TableA, disc_copies: nodes)
Memento.Table.create!(TableB, disc_copies: nodes)
Memento.Table.create!(TableC)
```

This needs to be done only once and not every time the application starts. It also makes sense to create a helper
function or mix task that does this for you. You can see a [sample implementation here][que-persistence].

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
    - [x] wait
    - [ ] Ecto-like DSL
    - [ ] Migration Support
 - [x] Memento.Query
    - [x] Integration with Memento.Table
    - [x] match/select
    - [x] read/write/delete
    - [ ] first/next/prev/all_keys
    - [ ] test matchspec
    - [ ] continue/1 for select continuations
    - [x] autoincrement
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




## FAQ



#### 1. Why Memento/Mnesia?

In most applications, some kind of data storage mechanism is needed, but this usually means relying on some sort
of external dependency or program. Memento should be used in situations when it might not always make sense in an
Application to do this (e.g. the data is ephemeral, the project needs to be kept light-weight, you need a simple
data store that persists across application restarts, data-code decoupling is not important etc.).


#### 2. When shouldn't I use Memento/Mnesia?

Like mentioned in the previous point, Memento/Mnesia has specific use-cases and it might not always make sense to
use it. This is usually when you don't want to couple your code and database, and want to allow independent or
external accesses to transformation of your data. In such circumstances, you should always prefer using some other
datastore (like Redis, Postgres, etc.).


#### 3. Isn't there already an 'Amnesia' library?

I've been a long-time user of the [`Amnesia`][amnesia] package, but with the recent releases of Elixir (1.5 & above),
the library has started to show its age. Amnesia's dependence on the the `exquisite` package has caused a lot of
compilation problems, and it's complex macro-intensive structure hasn't made it easy to fix them either. The library
itself doesn't even compile in Elixir 1.7+ so I finally decided to write my own after I desperately needed to update
my Mnesia-based projects.

Memento is meant to be an extremely lightweight wrapper for Mnesia, providing a very easy set of helpers and forcing
good decisions by avoiding the "dirty" methods.


#### 4. Are there any other projects that are using Memento?

Memento is a new package so there aren't many Open Source examples available. [Que][que] is another library
that uses Memento for background job processing and storing the state of these Jobs. If your project uses
Memento, feel free to send in a pull-request so it can be mentioned here.

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
  [amnesia]:              https://github.com/meh/amnesia

  [docs]:                 https://hexdocs.pm/memento
  [docs-transaction]:     https://hexdocs.pm/memento/Memento.Transaction.html
  [docs-table]:           https://hexdocs.pm/memento/Memento.Table.html
  [docs-query]:           https://hexdocs.pm/memento/Memento.Query.html
  [docs-query-select]:    https://hexdocs.pm/memento/Memento.Query.html#select/3

  [github-fork]:          https://github.com/sheharyarn/memento/fork
  [que-persistence]:      https://github.com/sheharyarn/que/blob/dc3764a27f8ce3e28b15a7bfafbca604fb424ecb/lib/que/persistence/mnesia/mnesia.ex#L90-L108

