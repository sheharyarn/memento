Memento
=======

> Nothing cool here yet, check back later


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


## License

MIT

