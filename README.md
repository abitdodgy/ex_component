# ExComponent

This library provides a DSL for generating HTML components.

```elixir
include ExComponent

defcomp(:alert, type: {:content_tag, :div}, class: "alert", variants: [:success])

alert :success do
  "Alert!"
end
#=> <div class="alert alert-success">Alert!</div>

alert(:success, "Alert!")
#=> <div class="alert alert-success">Alert!</div>
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

