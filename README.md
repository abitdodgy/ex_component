# ExComponent

A DSL for easily building dynamic, reusable components for your frontend framework in Elixir.

```elixir
include ExComponent

defcontenttag :alert, tag: :div, class: "alert",
  variants: [
    primary: [class: "alert-primary"],
    success: [class: "alert-success"]
  ]

alert :primary, "Alert!"
#=> <div class="alert alert-primary">Alert!</div>

alert :primary, "Alert!", class: "extra"
#=> <div class="alert alert-primary extra">Alert!</div>

alert :success, "Alert!"
#=> <div class="alert alert-success">Alert!</div>
```

Generated function clauses accept a block and a list of opts.

```elixir
alert :primary, class: "extra" do
  "Alert!"
end
#=> <div class="alert alert-primary extra">Alert!</div>
```

This lib is a work in progress and its API might change.

Please see internal docs for extensive usage examples.

## Installation

The package can be installed by adding `ex_component` to your list of dependencies in `mix.exs`:

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
