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
    variants = Keyword.get(options, :variants)

    quote do
      @doc """
      Generates a `#{unquote(name)}/2` component. Accepts a list of options that is passed
      onto the underlying HTML.

      If the component is provided the `:variants` option, generates a `#{unquote(name)}/3` function
      where the variant is the first argument.

      ## Examples

          #{unquote(name)} do
            "..."
          end
          #=> <tag class="#{unquote(name)}">...</tag>

          #{unquote(name)} class: "extra" do
            "..."
          end
          #=> <tag class="#{unquote(name)} extra">...</tag>

      #{
        if unquote(variants) do
          ~s(    #{unquote(name)} :variant, do: \"...\"\n) <>
            ~s(    #=> <tag class=\"#{unquote(name)} variant\">...</tag>\n\n) <>
            ~s(    #{unquote(name)} :variant, class: \"extra\", do: \"...\"\n) <>
            ~s(    #=> <tag class=\"#{unquote(name)} variant extra\">...</tag>\n\n)
        end
      }

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
      if unquote(variants) do
        def unquote(name)(variant, do: block) when is_atom(variant),
          do: unquote(name)(variant, block, [])

        def unquote(name)(variant, content) when is_atom(variant),
          do: unquote(name)(variant, content, [])

        def unquote(name)(variant, opts, do: block) do
          unquote(name)(variant, block, opts)
        end

        def unquote(name)(variant, content, opts) do
          render(content, [variants: [variant]] ++ opts, unquote(options))
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
      @doc """
      Generates a `#{unquote(name)}/1` component. Accepts a list of options that is passed
      onto the underlying HTML.

      If the component is provided the `:variants` option, generates a `#{unquote(name)}/3` function
      where the variant is the first argument.

      ## Examples

          #{unquote(name)}
          #=> <tag class="#{unquote(name)}">

          #{unquote(name)} class: "extra"
          #=> <tag class="#{unquote(name)} extra">>

      #{
        if unquote(variants) do
          ~s(    #{unquote(name)} :variant\n) <>
            ~s(    #=> <tag class=\"#{unquote(name)} variant\">\n\n) <>
            ~s(    #{unquote(name)} :variant, class: \"extra\""\n) <>
            ~s(    #=> <tag class=\"#{unquote(name)} variant extra\">\n\n)
        end
      }

      ## Options

      Besides any opts that can be forwarded onto `PHoenix.HTML.Tag`, the following
      options are specific to ExComponent.

        + `:tag` - overrides the given tag in the `:type` component option.

        + `:parent` - overrides the component;s `:parent` option in @moduledoc.

        + `:variants` - a list of variants.

      """
      if unquote(variants) do
        def unquote(name)(variant) when is_atom(variant) do
          unquote(name)(variants: [variant])
        end

        def unquote(name)(variant, opts) when is_atom(variant) do
          unquote(name)([variants: [variant]] ++ opts)
        end
      end

      def unquote(name)(), do: unquote(name)([])

      def unquote(name)(opts) do
        render(opts, unquote(options))
      end
    end
  end

  @doc false
  def render(opts, defaults) do
    {opts, private_opts} = merge_default_opts(opts, defaults)

    opts
    |> put_component(private_opts)
    |> put_content(:parent, opts)
  end

  @doc false
  def render(opts, defaults, do: block) do
    render(block, opts, defaults)
  end

  @doc false
  def render(content, opts, defaults) do
    {opts, private_opts} = merge_default_opts(opts, defaults)

    [content]
    |> put_content(:wrap_content, opts)
    |> put_children(opts)
    |> put_component(opts, private_opts)
    |> put_content(:parent, opts)
  end

  defp merge_default_opts(opts, defaults) do
    private_opts = Keyword.take(defaults, [:class, :variants, :options])

    default_opts =
      defaults
      |> Keyword.drop([:class, :variants, :options])

    opts =
      opts
      |> Keyword.get(:variants, [])
      |> Enum.reduce(default_opts, fn variant, acc ->
        variant_opts = get_in(private_opts, [:variants, variant])
        Keyword.merge(acc, variant_opts)
      end)
      |> Keyword.delete(:class)
      |> Keyword.merge(opts)

    {opts, private_opts}
  end

  defp put_children(content, opts) do
    opts
    |> Keyword.take([:append, :prepend])
    |> Enum.reduce(content, fn {position, child}, acc ->
      case position do
        :append ->
          [acc | make_child(child)]

        :prepend ->
          [make_child(child) | acc]
      end
    end)
  end

  defp make_child({:safe, _content} = child), do: child
  defp make_child(child) when is_atom(child), do: tag(child)
  defp make_child({tag, opts}) when is_list(opts), do: tag(tag, opts)
  defp make_child({tag, content}), do: content_tag(tag, content)
  defp make_child({tag, content, opts}), do: content_tag(tag, content, opts)

  defp put_component(opts, private_opts) do
    tag = Keyword.get(opts, :tag)
    opts = put_class(opts, private_opts)
    
    tag(tag, opts)
  end

  defp put_component(content, opts, private_opts) do
    tag = Keyword.get(opts, :tag)
    opts = put_class(opts, private_opts)

    case tag do
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

  defp put_class(opts, private_opts) do
    class =
      opts
      |> put_class_and_variant(private_opts)
      |> put_options(opts, private_opts)
      |> put_user_class(opts)
      |> filter()

    opts
    |> clean_opts(private_opts)
    |> Keyword.put(:class, class)
  end

  defp filter(class_list) do
    class_list
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp put_class_and_variant(opts, private_opts) do
    base_class = Keyword.fetch!(private_opts, :class)

    opts
    |> Keyword.get(:variants, [])
    |> case do
      [] ->
        [base_class]

      variants ->
        Enum.flat_map(variants, fn variant ->
          private_opts
          |> get_in([:variants, variant])
          |> get_variant_class(base_class)
        end)
        |> Enum.uniq()
    end
  end

  defp get_variant_class(variant, base_class) do
    class = Keyword.get(variant, :class)

    case {
      Keyword.get(variant, :merge, true),
      Keyword.get(variant, :prefix, base_class)
    } do
      {true, false} ->
        [base_class, class]

      {true, prefix} ->
        [base_class, "#{prefix}-#{class}"]

      {false, false} ->
        [class]

      {false, prefix} ->
        ["#{prefix}-#{class}"]
    end
  end

  defp put_options(list, opts, private_opts) do
    base_class = Keyword.fetch!(private_opts, :class)

    class =
      private_opts
      |> Keyword.get(:options, [])
      |> Enum.map(fn option ->
        opts
        |> Keyword.get(option)
        |> case do
          nil ->
            nil

          true ->
            ~s(#{base_class}-#{option})

          value ->
            ~s(#{base_class}-#{option}-#{value})
        end
      end)

    List.insert_at(list, -1, class)
  end

  defp put_user_class(list, opts) do
    class = Keyword.get(opts, :class)
    List.insert_at(list, -1, class)
  end

  defp clean_opts(opts, private_opts) do
    options = Keyword.get(private_opts, :options, [])

    opts
    |> Keyword.drop(options)
    |> Keyword.drop([:variants, :merge, :prefix])
    |> Keyword.drop(@overridable_opts)
  end
end
