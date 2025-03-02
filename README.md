# vector_clocks

This is a partial port of [Riak's vector
clocks](https://github.com/basho/riak_core/blob/develop/src/vclock.erl) to
Gleam.

Features such as prunning and timestamps are missing. This means that
last-write wins conflict resolution (as is default in Riak) is not possible.

Adding timestamps is easy and is left as an exercise for the reader.

> [!TODO]
> Add a visualization or something

## License
MIT

