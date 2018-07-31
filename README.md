<!-- Heading: Start -->
<h1 align="center">
  <a href="https://hexdocs.pm/memento">
    <img alt="Memento" src='media/logo.png' width='500px'/>
  </a>
</h1>

<p align="center">
  <!-- Build Status -->
  <a href="https://travis-ci.org/sheharyarn/memento">
    <img alt="Build Status" src="https://img.shields.io/travis/sheharyarn/memento/master.svg" />
  </a>

  <!-- Coverage -->
  <a href="https://hexdocs.pm/memento">
    <img alt="Coverage" src="https://inch-ci.org/github/sheharyarn/memento.svg?branch=master" />
  </a>

  <!-- Version -->
  <a href="https://hex.pm/packages/memento">
    <img alt="Version" src="https://img.shields.io/hexpm/v/memento.svg" />
  </a>

  <!-- License -->
  <a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/hexpm/l/memento.svg" />
  </a>
</p>

<p align="center">
  <b>Powerful yet Easy-to-Use Mnesia Interface for Elixir</b></br>
  <sub>Mnesia. Memento. <a href="https://www.imdb.com/title/tt0209144/">Get it?</a><sub>
</p>
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
