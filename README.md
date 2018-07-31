<!-- Heading: Start -->
<h1 align="center">
  [<img alt="Memento" src='media/logo.png' width='500px'/>][docs]
</h1>

<span align="center">
  [![Build Status][shield-travis]][travis-ci]
  [![Coverage Status][shield-inch]][docs]
  [![Version][shield-version]][hexpm]
  [![License][shield-license]][hexpm]
</span>

> Mnesia. Memento. [Get it?][imdb-memento]

<!-- Heading: End -->


## Installation

```elixir
def deps do
  [{:memento, "~> 0.0.1"}]
end
```


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


## License

MIT


  [imdb-memento]: https://www.imdb.com/title/tt0209144/


  [logo]:             media/logo.png
  [shield-version]:   https://img.shields.io/hexpm/v/que.svg
  [shield-license]:   https://img.shields.io/hexpm/l/que.svg
  [shield-downloads]: https://img.shields.io/hexpm/dt/que.svg
  [shield-travis]:    https://img.shields.io/travis/sheharyarn/que/master.svg
  [shield-inch]:      https://inch-ci.org/github/sheharyarn/que.svg?branch=master

  [travis-ci]:        https://travis-ci.org/sheharyarn/que
  [inch-ci]:          https://inch-ci.org/github/sheharyarn/que

  [license]:          https://opensource.org/licenses/MIT
  [mnesia]:           http://erlang.org/doc/man/mnesia.html
  [hexpm]:            https://hex.pm/packages/que

  [docs]:             https://hexdocs.pm/que
  [docs-worker]:      https://hexdocs.pm/que/Que.Worker.html
  [docs-mix]:         https://hexdocs.pm/que/Mix.Tasks.Que.Setup.html
  [docs-setup-prod]:  https://hexdocs.pm/que/Que.Persistence.Mnesia.html#setup!/0

  [github-fork]:      https://github.com/sheharyarn/que/fork
