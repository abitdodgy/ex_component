defmodule ExComponent do
  @moduledoc """
  A DSL for building reusable components in EEx.

      defcontenttag :card, tag: :div, class: "card"

      card do
        "Content!"
      end
      #=> <div class="card">Content!</div>

      defcontenttag :alert, tag: :div, class: "alert", variants: [:primary, :success]

      alert :primary, "Alert!"
      #=> <div class="alert alert-primary">Alert!</div>

      alert :primary, "Alert!", class: "extra"
      #=> <div class="alert alert-primary extra">Alert!</div>

      alert :success, "Alert!"
      #=> <div class="alert alert-success">Alert!</div>

  Generated function clauses accept a block and a list of opts.

      alert :primary, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-primary extra">Alert!</div>

  ## Usage

  The lib defines two macros, `deftag` and `defcontenttag`.

  Use `deftag` to define void components, those that do not accept their
  own content, like `hr`.

  Use `defcontent` to define components that accept their own content, like `div`.

  ### `:class`

  The `:class` is the base class of the component and is used to build
  variant classes in the form `class="{class class-variant}"`.

  ### `:variants`

  The `:variants` option adds a modifier class to the component and automatically
  generates `component/3` function clauses for each variant, where the variant is the
  first argument.

      defcontenttag :alert, tag: :div, class: "alert", variants: [:success]

      alert :success, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-success extra">Alert!</div>

  For components that can have multiple variants, use `component/2` and
  pass a list to the `:variant` option.

      list_group variant: [:flush, :horizontal], class: "extra" do
        "..."
      end
      #=> <div class="list-group list-group-flush list-group-horizontal ">...</div>

  ### `:variant_class_prefix`

  You can override the variant base class with the `:variant_class_prefix`. This is useful for defining
  variants that do not inherit the base class, or have a custom class.

  For example, the `dropup` and `dropleft` variants of Bootstrap's dropdowns.

  ### `:append` and `:prepend`

  The `:append` and `:prepend` options are useful adding additional content the component's HTML.

  For example, an an alert component that has a close button.

    defcontenttag :close_button, tag: :button, class: "close", data: [dismiss: "alert"], aria: [label: "Close"]
    defcontenttag :alert, tag: :div, class: "alert", prepend: close_button("&times;"), variants: [:primary]

    # Or

    defcontenttag :alert, tag: :div, class: "alert", prepend: :hr, variants: [:primary]
    defcontenttag :alert, tag: :div, class: "alert", prepend: {:h6, "Hold Up!", class: "alert-title"}, variants: [:primary]

    alert :primary do
      "Content"
    end
    #=> <div class="alert alert-primary">
          <button aria-label=\"Close\" class=\"close\" data-dismiss=\"alert\">
            <span>&times;</span>
          </button>
          Content
        </div>

  ### `:parent`

  The `:parent` option is useful for nesting a component in an additional tag.

  You can pass an atom, or a tuple with either a function or an atom, and a
  list of parent options.

  For example, breadcrumbs in Bootstrap are built with an `ol` tag wrapped in a `nav` tag.

      <nav role="nav">
        <ol class="breadcrumbs">
          <li class="breadcrumbs-item">...</li>
        </ol>
      </nav>

  You can use the `parent: :nav` and `parent: {:nav, [role: "nav"]}` to address this case.

      defcomp :breadcrumbs, tag: :ol, ..., parent: :nav
      defcomp :breadcrumbs, tag: :ol, ..., parent: {:nav, [role: "nav"]}

  ## Options

    * `:class` - the component's class name. This option is required.

    * `:html_opts` - a list of opts to forward onto the HTML.

    * `:parent` - wraps the component in the given tag. Accepts a tuple where the first element is the parent tag and the second is a list of parent options. For example, `{:div, [class: "something"]}`.

    * `:prepend` - prepends the given tag to the component's content. Accepts a tuple in the following format: `{:tag, "Content", opts_list}` or `{:tag, opts_list}`. For example, `{:hr, [class: "divider"]}` or `{:button, "Dropdown", class: "extra"}`.

    * `:append` - appends the given content to the component. Accepts a tuple in the following format: `{:tag, "Content", opts_list}` or `{:tag, opts_list}`. For example, `{:hr, [class: "divider"]}` or `{:button, "Dropdown", class: "extra"}`.

    * `:variants` - a list of component variants. Each variant generates a `component/3` (`component/2` for `deftag`) function clause where an atom variant name is the first argument.

    * `:variant_class_prefix` - the class prefix to use when composing variants. Defaults to the `class` option. Use `false` for no prefix.


  """

  # append, prepend: :hr, {:div, "content", []}, {:div, "content", []}
  # wrap: :div, {:div, []}
  # type: :div, &func

  import Phoenix.HTML.Tag,
    only: [
      tag: 2,
      content_tag: 3
    ]

  @overridable_opts ExComponent.Config.get_config(:overridable_opts)

  defmacro defcontenttag(name, options) do
    variants = Keyword.get(options, :variants)

    quote do
      if unquote(variants) do
        def unquote(name)(variant, do: block) when is_atom(variant),
          do: unquote(name)(variant, block, [])

        def unquote(name)(variant, content) when is_atom(variant),
          do: unquote(name)(variant, content, [])

        def unquote(name)(variant, opts, do: block) do
          unquote(name)(variant, block, opts)
        end

        def unquote(name)(variant, content, opts) do
          render(content, [variants: variant] ++ opts, unquote(options))
        end
      end

      def unquote(name)(do: block), do: unquote(name)(block, [])
      def unquote(name)(content), do: unquote(name)(content, [])
      def unquote(name)(opts, do: block), do: unquote(name)(block, opts)
      def unquote(name)(content, opts), do: render(content, opts, unquote(options))
    end
  end

  defmacro deftag(name, options) do
    variants = Keyword.get(options, :variants)

    quote do
      if unquote(variants) do
        def unquote(name)(variant) when is_atom(variant) do
          unquote(name)(variants: variant)
        end

        def unquote(name)(variant, opts) when is_atom(variant) do
          unquote(name)([variants: variant] ++ opts)
        end
      end

      def unquote(name)(), do: unquote(name)([])

      def unquote(name)(opts) do
        render(opts, unquote(options))
      end
    end
  end

  @doc """
  Generates a HTML component. Accepts a list of options that is passed
  onto the underlying HTML.

  ## Options

  Besides any opts that can be forwarded onto PHoenix.HTML.Tag, the following
  options are specific to ExComponent.

    + `:tag` - overrides the given tag in the `:type` component option.

    + `:append` - overrides the component's `:append` option in @moduledoc.

    + `:parent` - overrides the component;s `:parent` option in @moduledoc.

    + `:prepend` - overrides the component's `:prepend` option in @moduledoc.

    + `:variants` - a list of variants.

  """
  def render(opts, defaults) do
    {opts, defaults} = merge_default_opts(opts, defaults)

    opts
    |> put_component(defaults)
    |> put_parent(defaults)
  end

  def render(opts, defaults, do: block) do
    render(block, opts, defaults)
  end

  def render(content, opts, defaults) do
    {opts, defaults} = merge_default_opts(opts, defaults)

    [content]
    |> put_children(defaults)
    |> put_component(opts, defaults)
    |> put_parent(defaults)
  end

  defp merge_default_opts(opts, defaults) do
    default_opts =
      defaults
      |> Keyword.get(:html_opts, [])
      |> Keyword.merge(opts)
      |> Keyword.drop(@overridable_opts)

    overridden_opts = Keyword.take(opts, @overridable_opts)
    component_opts = Keyword.merge(defaults, overridden_opts)

    {default_opts, component_opts}
  end

  defp put_children(content, opts) do
    # {:safe, iodata}, :div, {:div, "content"}, {:div, "content", opts}
    opts
    |> Keyword.take([:append, :prepend])
    |> Enum.reduce(content, fn {pos, child}, acc ->
      child =
        case child do
          {:safe, _content} ->
            child

          child when is_atom(child) ->
            make(child)

          child when is_tuple(child) ->
            apply(__MODULE__, :make, Tuple.to_list(child))
        end

      case pos do
        :append ->
          [acc | child]

        :prepend ->
          [child | acc]
      end
    end)
  end

  def make(name), do: make(name, [])
  def make(name, opts) when is_list(opts), do: tag(name, opts)
  def make(name, content) when is_function(name), do: apply(name, [content])
  def make(name, content), do: make(name, content, [])
  def make(name, content, opts) when is_function(name), do: apply(name, [content, opts])
  def make(name, content, opts) when is_list(opts), do: content_tag(name, content, opts)

  defp put_component(opts, defaults) do
    opts = put_class(opts, defaults)

    defaults
    |> Keyword.get(:tag)
    |> tag(opts)
  end

  defp put_component(content, opts, defaults) do
    opts = put_class(opts, defaults)

    defaults
    |> Keyword.get(:tag)
    |> make(content, opts)
  end
  
  defp put_parent(content, opts) do
    # nil, :div, &fun/1, {:div, opts}
    case Keyword.get(opts, :parent) do
      nil ->
        content

      {name, opts} ->
        make(name, content, opts)

      name ->
        make(name, content)

    end
  end

  defp put_class(opts, defaults) do
    base_class = Keyword.fetch!(defaults, :class)
    user_class = Keyword.get(opts, :class)

    variant_prefix = get_variant_prefix(defaults, base_class)

    variant_class =
      opts
      |> Keyword.get_values(:variants)
      |> List.flatten()
      |> Enum.map(fn variant ->
        make_variant(variant, variant_prefix)
      end)

    class =
      [base_class, variant_class, user_class]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    opts
    |> Keyword.delete(:variants)
    |> Keyword.put(:class, class)
  end

  defp get_variant_prefix(defaults, default) do
    defaults
    |> Keyword.get(:variant_class_prefix)
    |> case do
      nil ->
        default

      prefix ->
        prefix
    end
  end

  defp make_variant(variant, false), do: variant

  defp make_variant(variant, prefix) do
    Enum.join([prefix, dasherize(variant)], "-")
  end

  defp dasherize(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", "-")
  end
end
