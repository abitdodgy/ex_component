# ExComponent

This library provides a DSL for generating HTML components.

```elixir
include ExComponent

defcomp(:alert, arity: 3, class: "alert", default_tag: :div, variants: [:info, :danger])

alert(:info, "Alert!")
#=> <div class="alert alert-info">Alert!</div>

alert(:danger, "Alert!")
#=> <div class="alert alert-danger">Alert!</div>

defcomp(:list_group, class: "list-group", default_tag: :ul, variants: :flush)

list_group variant: :flush do
  ...
end
#=> <ul class="list-group list-group-flush">...</ul>
```

This lib is a work in progress and its API might change.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_component` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_component, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_component](https://hexdocs.pm/ex_component).

