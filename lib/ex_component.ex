defmodule ExComponent do
  @moduledoc """
  A DSL for easily building dynamic, reusable components for your frontend framework in Elixir.

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

  The lib defines two macros: `deftag` and `defcontenttag`.

  The `deftag` macro defines void components, those that do not accept their
  own content, like `hr`, while the `defcontenttag` macro defines components that accept
  their own content, like `div`.

  ### Function Delegation

  The `:tag` option accepts an atom and an anonymous function, which allows you to generate
  components that defer execution to another function.

  This is useful if you want to use `Phoenix.HTML.Link.link/2`, for example.

      defcontenttag :list_group_item, tag: &Phoenix.HTML.Link.link/2, class: "list-group-item"

      list_group_item "Action", to: "#"
      #=> <a href="#" class: "list-group-item">Action</a>

  ### CSS Class

  The `:class` option is the base class of the component and is used to build
  variant classes in the form `class="{class class-variant}"`.

  ### Variants

  The `:variants` option adds a modifier class to the component and generates `component/3`
  clauses for each variant, where the variant is the first argument.

      defcontenttag :alert, tag: :div, class: "alert", variants: [:success]

      alert :success, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-success extra">Alert!</div>

  Some components have multiple variants. You can use `component/2` and
  pass a list to the `:variants` option.

      list_group variants: [:flush, :horizontal], class: "extra" do
        "..."
      end
      #=> <div class="list-group list-group-flush list-group-horizontal ">...</div>

  ### Variant Class

  Some components have variants that do not inherit the component's base class, or
  have a custom class. For example, the `dropup` and `dropleft` variants of Bootstrap's dropdowns.

  Set `variant_class_prefix: false` to define a variant without a class prefix. You can also
  provide your own custom prefix.

      defcontenttag :dropdown, tag: :div, class: "dropdown", variants: [:dropup, :dropleft], variant_class_prefix: false

      dropdown :dropleft do
        ...
      end
      #=> <div class="dropdown dropleft">...</div>

  ### Appending and Prepending Content

  Use `:append` and/or `:prepend` to add additional content your component. For example, a Bootstrap
  alert that has a close button.

      defcontenttag :close, tag: :button, wrap_content: :span, class: "close", data: [dismiss: "alert"], aria: [label: "Close"]
      defcontenttag :alert, tag: :div, class: "alert", prepend: close("&times;"), variants: [:primary]

      alert :primary do
        "Content"
      end
      <div class="alert alert-primary">
        <button aria-label=\"Close\" class=\"close\" data-dismiss=\"alert\">
          <span>&times;</span>
        </button>
        Content
      </div>

  Both options accept an atom, or a tuple in one the forms `{:safe, iodata}`,
  `{:tag, opts}`, `{:tag, "content"}`, and `{:tag, "content", opts}`.

  ### Nesting Components

  The `:parent` option is useful for nesting a component in an additional tag.

  You can pass an atom, or a tuple with either a function or an atom, and a
  list of parent options.

  For example, breadcrumbs in Bootstrap are built with an `ol` tag wrapped in a `nav` tag.

      <nav role="nav">
        <ol class="breadcrumbs">
          <li class="breadcrumbs-item">...</li>
        </ol>
      </nav>

  You can use the `parent: :nav` or `parent: {:nav, [role: "nav"]}` to address this case.

      defcontenttag :breadcrumbs, tag: :ol, ..., parent: :nav
      defcontenttag :breadcrumbs, tag: :ol, ..., parent: {:nav, [role: "nav"]}

  You can also pass an anonymouse function to the parent option.

      defcontenttag :breadcrumbs, tag: :ol, ..., parent: &fun/1

  ### Wrapping Content

  The `:wrap_content` option works exactly like the `:parent` option except that it wraps the
  content of the component rather than the component itself.

  For example, a Bootstrap button whose text is wrapped in a `span`.

      defcontenttag :button, tag: :button, ..., wrap_content: :span

  ### Default HTML Options

  You can pass a list of HTML options to `:html_opts`, which gets forwarded to the underlying
  HTML. Any default options can be overriden during function calls.

  ## Options

    * `:class` - the component's class name. This option is required.

    * `:html_opts` - a list of opts to forward onto the HTML.

    * `:parent` - wraps the component in the given tag. Accepts an atom, a anonymous function, or a tuple where the first element is the parent tag and the second is a list of parent options. For example, `{:div, [class: "something"]}`.

    * `:prepend` - prepends the given tag to the component's content. Accepts a tuple in the following format: `{:safe, iodata}`, `{:tag, opts}`, `{:tag, "content"}`, or `{:tag, "content", opts}`. For example, `{:hr, [class: "divider"]}` or `{:button, "Dropdown", class: "extra"}`.

    * `:append` - appends the given content to the component. See the `:prepend` option for usage.

    * `:wrap_content` - wraps the inner content of the component in the given tag. See the `:parent` option for usage.

    * `:variants` - a list of component variants. Each variant generates a `component/3` (`component/2` for `deftag`) function clause where an atom variant name is the first argument.

    * `:variant_class_prefix` - the class prefix to use when composing variants. Defaults to the `class` option. Use `false` for no prefix.


  """
  import Phoenix.HTML.Tag,
    only: [
      tag: 1,
      tag: 2,
      content_tag: 2,
      content_tag: 3
    ]

  @overridable_opts ExComponent.Config.get_config(:overridable_opts)

  defmacro defcontenttag(name, options) do
    variants = Keyword.get(options, :variants, [])

    quote do
      @doc """
      Generates a `#{unquote(name)}/2` component. Accepts a list of options that is passed
      onto the underlying HTML.

      ## Examples

          #{unquote(name)} do
            "..."
          end
          #=> <... class="#{unquote(name)}">...</...>

          #{unquote(name)} class: "extra" do
            "..."
          end
          #=> <... class="#{unquote(name)} extra">...</...>

          #{Enum.each(unquote(variants), fn variant ->
              "#{unquote(name)} #{variant} do" <>
                "..." <>
              "end"
              #=> <... class="#{unquote(name)} :#{variant}">...</...>

              "#{unquote(name)} #{variant}, class: \"extra\" do" <>
                "..." <>
              "end"
              #=> <... class="#{unquote(name)} :#{variant} extra">...</...>
            end)}
          
      ## Options

      Besides any opts that can be forwarded onto `PHoenix.HTML.Tag`, the following
      options are specific to ExComponent.

        + `:tag` - overrides the given tag in the `:type` component option.

        + `:append` - overrides the component's `:append` option in @moduledoc.

        + `:parent` - overrides the component;s `:parent` option in @moduledoc.

        + `:prepend` - overrides the component's `:prepend` option in @moduledoc.

        + `:wrap_content` - overrides the component's `:wrap_content` option in @moduledoc.

        + `:variants` - a list of variants.

      """
      Enum.each(unquote(variants), fn variant ->
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
      end)

      def unquote(name)(do: block), do: unquote(name)(block, [])
      def unquote(name)(content), do: unquote(name)(content, [])
      def unquote(name)(opts, do: block), do: unquote(name)(block, opts)
      def unquote(name)(content, opts), do: render(content, opts, unquote(options))
    end
  end

  defmacro deftag(name, options) do
    variants = Keyword.get(options, :variants, [])

    quote do
      @doc """
      Generates a `#{unquote(name)}/1` component. Accepts a list of options that is passed
      onto the underlying HTML.

      ## Examples

          #{unquote(name)}
          #=> <... class="#{unquote(name)}">

          #{unquote(name)} class: "extra"
          #=> <... class="#{unquote(name)} extra">>

          #{Enum.each(unquote(variants), fn variant ->
              "#{unquote(name)} :#{variant}"
              #=> <... class="#{unquote(name)} :#{variant}">

              "#{unquote(name)} :#{variant}, class: \"extra\""
              #=> <... class="#{unquote(name)} :#{variant} extra">
            end)}
          
      ## Options

      Besides any opts that can be forwarded onto `PHoenix.HTML.Tag`, the following
      options are specific to ExComponent.

        + `:tag` - overrides the given tag in the `:type` component option.

        + `:parent` - overrides the component;s `:parent` option in @moduledoc.

        + `:variants` - a list of variants.

      """
      Enum.each(unquote(variants), fn variant ->
        def unquote(name)(variant) when is_atom(variant) do
          unquote(name)(variants: variant)
        end

        def unquote(name)(variant, opts) when is_atom(variant) do
          unquote(name)([variants: variant] ++ opts)
        end
      end)

      def unquote(name)(), do: unquote(name)([])

      def unquote(name)(opts) do
        render(opts, unquote(options))
      end
    end
  end

  @doc false
  def render(opts, defaults) do
    {opts, defaults} = merge_default_opts(opts, defaults)

    opts
    |> put_component(defaults)
    |> put_content(:parent, defaults)
  end

  @doc false
  def render(opts, defaults, do: block) do
    render(block, opts, defaults)
  end

  @doc false
  def render(content, opts, defaults) do
    {opts, defaults} = merge_default_opts(opts, defaults)

    [content]
    |> put_content(:wrap_content, defaults)
    |> put_children(defaults)
    |> put_component(opts, defaults)
    |> put_content(:parent, defaults)
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
    opts
    |> Keyword.take([:append, :prepend])
    |> Enum.reduce(content, fn {pos, child}, acc ->
      child =
        case child do
          {:safe, _content} ->
            child

          child when is_atom(child) ->
            tag(child)

          {tag, opts} when is_list(opts) ->
            tag(tag, opts)

          {tag, content} ->
            content_tag(tag, content)
          
          {tag, content, opts} ->
            content_tag(tag, content, opts)
        end

      case pos do
        :append ->
          [acc | child]

        :prepend ->
          [child | acc]
      end
    end)
  end

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
    |> case do
      fun when is_function(fun) ->
        apply(fun, [content, opts])

      tag ->
        content_tag(tag, content, opts)
    end
  end
  
  defp put_content(content, parent, opts) do
    opts
    |> Keyword.get(parent)
    |> case do
      nil ->
        content

      name when is_atom(name) ->
        content_tag(name, content)

      name when is_function(name) ->
        apply(name, [content])

      {name, opts} ->
        content_tag(name, content, opts)

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
