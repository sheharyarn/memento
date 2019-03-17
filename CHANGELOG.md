Changelog
=========


## v0.3.1

 - [Bugfix] Convert mnesia's `:"$end_of_table"` code to empty list
    - Previously raised UndefinedFunctionError during coercion



## v0.3.0

 - [Bugfix] Catch Mnesia exits _outside_ transactions (#2)
     - This fixes issues where Memento would unintentionally mess with Mnesia's
       deadlock resolution algorithm by catching exits, finally causing Mnesia to
       throw cyclic abort errors in high concurrency, nested transactions



## Before v0.3.0

Check the [commit history][commits].



  [commits]: https://github.com/sheharyarn/memento/commits/master

