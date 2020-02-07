# TransitElixir

This is a __very__ early library for working with the transit
data format.

For more information see: https://github.com/cognitect/transit-clj

### TODO:

Non-comprehensive list of remaining tasks

- [x] Support for escaping "Because the ~, ^, and ` characters have special meaning, any data string that begins with one of those characters is escaped by prepending a ~."
- [-] Caching
  - [x] Encoding symbols?
  - [x] Encoding keywords?
  - [x] Encoding maps
  - [ ] Key rollover
- [ ] URI
- [ ] Link
- [ ] Extend beyond the "built in" types

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `transit_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:transit_elixir, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/transit_elixir](https://hexdocs.pm/transit_elixir).

