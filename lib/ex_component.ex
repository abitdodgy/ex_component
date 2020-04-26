defmodule ExComponent do
  @moduledoc """
  A DSL for easily building dynamic, reusable components for your frontend framework in Elixir.

      defcontenttag :card, tag: :div, class: "card"

      card do
        "Content!"
      end
      #=> <div class="card">Content!</div>

      defcontenttag :alert,
        tag: :div,
        class: "alert",
        variants: [
          primary: [class: "primary"],
          success: [class: "success"]
        ]

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

  ## Function Delegation

  The `:tag` option accepts an atom and an anonymous function (when using `defcontenttag`),
  which allows you to generate components that defer execution to another function.

  This is useful if you want to use `Phoenix.HTML.Link.link/2`, for example.

      defcontenttag :list_group_item, tag: &Phoenix.HTML.Link.link/2, class: "list-group-item"

      list_group_item "Action", to: "#"
      #=> <a href="#" class: "list-group-item">Action</a>

  ## CSS Class

  The `:class` option is the base class of the component and is used to build
  variants and options. See the Variants section below for details.

  ## Variants

  A variant generates a `name/3` function clause that takes the variant name as its first argument.

  Variants are a handy way to define the same component in different contexts.

      defcontenttag :button,
        tag: :button,
        class: "btn",
        variants: [
          success: [class: "success"],
          primary: [class: "primary"],
          dropdown: [
            class: "toggle-dropdown", prefix: false,
            data: [toggle: "dropdown"],
            aria: [haspopup: true, expanded: false]
          ]
        ]

        button :success do
          "Success!"
        end
        #=> <button class="btn btn-success">Success!</button>

        button :dropdown do
          "Dropdown!"
        end
        #=> <button class="btn toggle-dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Dropdown!</button>

  You can combine variants by passing a named option with a list.

        button variants: [:success, :dropdown] do
          "Dropdown!"
        end
        #=> <button class="btn btn-success toggle-dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Dropdown!</button>

  ### Merge

  Each declared variant has a `:merge` option that defaults to `true`. While it's handy for declaring
  contextual (`class="alert alert-{success|danger}"`) variants that inherit the parent component class, sometimes
  you may want to customise or remove the component class.

      defcontenttag :dropdown,
        tag: :ul,
        class: "dropdown",
        variants: [
          dropup: [class: "dropup", merge: false]
        ]

      dropdown :dropup do
        "Dropup!"
      end
      #=> <ul class="dropup">...</ul>

      dropdown :dropdown do
        "Dropup!"
      end
      #=> <ul class="dropdown">...</ul>

  ### Prefix

  The prefix is a shortcut for prefixing the component's class to the variant class. It default's to
  the component's `:class` option. The following three examples are equivalent.

        defcontenttag :alert,
          tag: :div,
          class: "alert",
          variants: [
            primary: [class: "primary"]
          ]

      defcontenttag :alert,
          tag: :div,
          class: "alert",
          variants: [
            primary: [class: "alert-primary", prefix: false]
          ]

      defcontenttag :alert,
          tag: :div,
          class: "alert",
          variants: [
            primary: [class: "primary", prefix: "alert"]
          ]

  ## Declaring Options

  You can declare a list of options that can be used during function calls. This is handy for combining
  with variants to create complex class combinations.

      defcontenttag :col,
          tag: :div,
          class: "col",
          options: [:sm, :md, :lg, :auto]

      col auto: true, sm: 6, md: 4 do
        "Col!"
      end
      #=> <div class="col col-auto col-sm-6 col-md-4">...</div>

  In the above example, you may not want to use the `col` class since you are declaring `col`. In this case,
  combine with variants for the desired combinations.

      defcontenttag :col,
          tag: :div,
          class: "col",
          variants: [
            auto: [class: "auto"],
            sm: [class: "sm"],
            md: [class: "md"],
            lg: [class: "lg"],
          ],
          options: [:auto, :sm, :md, :lg]

      col :auto, sm: 6, md: 4 do
        "Col!"
      end
      #=> <div class="col-auto col-sm-6 col-md-4">...</div>

  Note that, options can:

  + have their component's class prefixed;
  
  + be passed `true` to use the option's name as the class rather than an explicit value.

  ## On Variants And Options

  While combining these options is powerful, sometimes it's best to go for simpliciy. The examples
  above can be declared as separate components.

      defcontenttag :col_auto,
          tag: :div,
          class: "col-auto",
          options: [:auto, :sm, :md, :lg]

      defcontenttag :col_sm,
          tag: :div,
          class: "col-sm",
          options: [:auto, :sm, :md, :lg]

      col_auto sm: 6, md: 4 do
        "Col!"
      end
      #=> <div class="col-auto col-sm-6 col-md-4">...</div>

      col_sm md: 4 do
        "Col!"
      end
      #=> <div class="col-sm col-md-4">...</div>

  ### Appending And Prepending Content

  You can append or prepend additional components to your component's content by using `:append` and/or `:prepend`.

  For example, a Bootstrap alert can have a close button.

      defcontenttag :close, tag: :button, wrap_content: :span, class: "close", data: [dismiss: "alert"], aria: [label: "Close"]
      defcontenttag :alert, tag: :div, class: "alert", prepend: close("&times;"), variants: [primary: [class: "primary"]]

      alert :primary do
        "Content"
      end
      <div class="alert alert-primary">
        <button aria-label="Close" class="close" data-dismiss="alert">
          <span>&times;</span>
        </button>
        Content
      </div>

  Both options accept an atom or a tuple in one the forms `{:safe, iodata}`, `{:tag, opts}`, `{:tag, "content"}`, and `{:tag, "content", opts}`.

  ### Nesting Components

  The `:parent` option is useful for nesting a component in an additional tag. You can pass
  an atom, or a tuple with either a function or an atom, and a list of parent options.

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

  Any additional options declared in the component definition are forwarded onto the underlying HTML. Default options can be overriden during function calls.

  ## Options

    * `:tag` - the component's tag. Can be an atom or an anonymous function.

    * `:class` - the component's class name. This option is required.

    * `:parent` - wraps the component in the given tag. Accepts an atom, a anonymous function, or a tuple where the first element is the parent tag and the second is a list of parent options. For example, `{:div, [class: "something"]}`.

    * `:prepend` - prepends the given tag to the component's content. Accepts a tuple in the following format: `{:safe, iodata}`, `{:tag, opts}`, `{:tag, "content"}`, or `{:tag, "content", opts}`. For example, `{:hr, [class: "divider"]}` or `{:button, "Dropdown", class: "extra"}`.

    * `:append` - appends the given content to the component. See the `:prepend` option for usage.

    * `:wrap_content` - wraps the inner content of the component in the given tag. See the `:parent` option for usage.

    * `:variants` - a keyword list of component variants. Each variant generates a `component/3` (`component/2` for `deftag`) function clause where an atom variant name is the first argument.

    * `:options` - a list of options that the component can accept, which generate additional classes.


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

        + `:tag` - overrides the `:tag` option in the component definition.

        + `:append` - overrides the `:append` option in the component defintion.

        + `:parent` - overrides the `:parent` option in component definition.

        + `:prepend` - overrides the `:prepend` option in the component defintion.

        + `:wrap_content` - overrides the `:wrap_content` option in the component definition.

        + `:variants` - a list of variants. Variants must be declared in the component definition.

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

        + `:tag` - overrides the `:tag` option in the component definition.

        + `:parent` - overrides the `:parent` option in component definition.

        + `:variants` - a list of variants. Variants must be declared in the component definition.

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
