<!-- Heading: Start -->
<br/>

<h1 align="center">
  <a href="https://hexdocs.pm/memento">
    <img alt="Memento" src='media/logo.png' width='400px'/>
  </a>
</h1>

<p align="center">
  <!-- Build Status -->
  <a href="https://travis-ci.org/sheharyarn/memento"><img alt="Build Status" src="https://img.shields.io/travis/sheharyarn/memento/master.svg" /></a>

  <!-- Coverage -->
  <a href="https://hexdocs.pm/memento"><img alt="Coverage" src="https://inch-ci.org/github/sheharyarn/memento.svg?branch=master" /></a>

  <!-- Version -->
  <a href="https://hex.pm/packages/memento"><img alt="Version" src="https://img.shields.io/hexpm/v/memento.svg" /></a>

  <!-- License -->
  <a href="./LICENSE"><img alt="License" src="https://img.shields.io/hexpm/l/memento.svg" /></a>
</p>

<p align="center">
  <b>Simple yet Powerful Elixir interface to the Erlang Mnesia Database</b></br>
  <sub>Mnesia. Memento. <a href="https://www.imdb.com/title/tt0209144/">Get it?</a><sub>
</p>

<br/>
<!-- Heading: End -->




Memento is an extremely easy-to-use and powerful wrapper in Elixir that makes is very easy and intuitive to work with
[Mnesia][mnesia], the Erlang Distributed Realtime Database. The original Mnesia API in Erlang is convoluted, unorganized
and combined with the complex `MatchSpec` and `QLC` query language, is hard to work with in Elixir, especially for
beginners that don't know much about Erlang. Memento attempts to define a simple API to work with tables, removing the
majority of complexity associated with it.


 - **Easy to Use:** Provides a simple & intuitive API for working with Mnesia.
 - **Real-time:** Has extremely fast real-time data searches, even across many nodes.
 - **Powerful Queries:** Provides a powerful Query interface on top of Erlang's MatchSpec and QLC, that is much easier to use.
 - **Persistence & Replication:** Schema can be coherently kept on disc & in memory, and can be replicated at several nodes.
 - **Atomic Transactions:** A series of Table-manipulation operations can be grouped in to a single atomic transaction.
 - **Focused:** Encourages good patterns by omitting dirty calls to the database.
 - **Mnesia Compatible:** You can still use Mnesia methods for Schemas and Tables created by Memento.
 - **No Dependencies:** Doesn't have any external dependencies; Only uses the built-in Mnesia module.
 - **MIT Licensed**: Free for personal and commercial use.


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

_It is highly recommended that you only add `:memento` and not `:mnesia` along with it._ This will ensure that that OTP calls
to Mnesia go through the Supervisor spec specified in Memento.


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





  [logo]:             media/logo.png
  [shield-version]:   https://img.shields.io/hexpm/v/memento.svg
  [shield-license]:   https://img.shields.io/hexpm/l/memento.svg
  [shield-downloads]: https://img.shields.io/hexpm/dt/memento.svg
  [shield-travis]:    https://img.shields.io/travis/sheharyarn/memento/master.svg
  [shield-inch]:      https://inch-ci.org/github/sheharyarn/memento.svg?branch=master

  [travis-ci]:        https://travis-ci.org/sheharyarn/memento
  [inch-ci]:          https://inch-ci.org/github/sheharyarn/memento

  [license]:          ./LICENSE
  [mnesia]:           http://erlang.org/doc/man/mnesia.html
  [hexpm]:            https://hex.pm/packages/memento
  [imdb-memento]:     https://www.imdb.com/title/tt0209144/

  [docs]:             https://hexdocs.pm/memento

  [github-fork]:      https://github.com/sheharyarn/memento/fork
