defmodule ExComponent do
  @moduledoc """
  A DSL for easily building dynamic, reusable components for your frontend framework in Elixir.

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

  The `:tag` option accepts an atom and, when using `defcontenttag`, an anonymous function,
  which allows you to generate components that defer execution to another function.

  This is useful if you want to use `Phoenix.HTML.Link.link/2`, for example.

      defcontenttag :list_group_item, tag: &Phoenix.HTML.Link.link/2, class: "list-group-item"

      list_group_item "Action", to: "#"
      #=> <a href="#" class: "list-group-item">Action</a>

  ## CSS Class

  The `:class` option is the base class of the component and can be used to build
  variants and options. See the Variants section below for details.

  ## Variants

  Variants are a handy way to define the same component in different contexts and generate
  a `name/3` function clause that takes the variant name as its first argument.

      defcontenttag :button, tag: :button, class: "btn",
        variants: [
          success: [class: "btn-success"],
          primary: [class: "btn-primary"],
          dropdown: [
            class: "toggle-dropdown", data: [toggle: "dropdown"], aria: [haspopup: true, expanded: false]
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

  ### Variant Class vs Component Class

  Each declared variant has a `:merge` option that defaults to `true`. When `true` this option
  appends the variant class to the component class.

      defcontenttag :alert, tag: :div, class: "alert",
        variants: [
          primary: [class: "alert-primary"],
          success: [class: "alert-success"],
        ]

      alert :primary, "Alert!"
      #=> <div class="alert alert-primary">Alert!</div>

  The above example gets the class `alert` from the component and the class `alert-primary` from
  the variant.

  While this is handy for declaring contextual variants that inherit the component's class, you may
  want more control over this behaviour. In such cases, `:merge` can be set to `false` or a custom value.

  The Bootstrap dropup is a great example when control over the `:merge` option can be handy.

      #=> <ul class="dropdown">...</ul>
      #=> <ul class="dropup">...</ul>

      defcontenttag :dropdown, tag: :ul, class: "dropdown",
        variants: [
          dropup: [class: "dropup", merge: false]
        ]

      dropdown :dropup do
        "Dropup!"
      end
      #=> <ul class="dropup">...</ul>

      dropdown :dropdown do
        "Dropdown!"
      end
      #=> <ul class="dropdown">...</ul>

  ### Variant Prefix

  The `:prefix` is a shortcut for prefixing the component's or a custom class to the variant class. It defaults
  to `false`. The following three examples are equivalent.

      defcontenttag :alert, tag: :div, class: "alert",
          variants: [
            primary: [class: "primary", prefix: true]
          ]

        defcontenttag :alert, tag: :div, class: "alert",
          variants: [
            primary: [class: "alert-primary"]
          ]

      defcontenttag :alert, tag: :div, class: "alert",
          variants: [
            primary: [class: "primary", prefix: "alert"]
          ]

  ### Using Variants As Options

  Any variant can be used as an option by passing it `option: true`. This means you can use the variant
  as a key-value pair along with other options, like `:class`, for example.

      defcontenttag :alert, tag: :div, class: "alert",
          variants: [
            primary: [class: "alert-primary", option: true]
          ]

      alert primary: true do
        "..."
      end
      #=> <div class="alert alert-primary">...</div>

  You can pass a boolean or a custom string to the option when making the function call.

  When you enable a variant as an option, it uses the variant's `:prefix` setting.

  See Declaring Options for more information.

  ## Adding Custom Options

  You can create and use any custom options, which are similar to variants but they do not
  define a `name/3` clause and only affect the CSS class of the component.

  Any defined options can be passed as key-value pairs along with other options when calling
  the fuction, as you would for `:class` or any other option.

      col :variant, option: value, option: value, ... do
        "Col!"
      end

  Unlike variants, options only compose CSS classes, while variants accept any HTML options that they
  forward onto the HTML.

      defcontenttag :col, tag: :div, class: "col",
          options: [
            sm: [class: "col-sm"],
            auto: [class: "col-auto"]
          ]

      col auto: true, sm: 6 do
        "Col!"
      end
      #=> <div class="col col-auto col-sm-6">...</div>

  ### Option Prefix

  Like variants, options also accept a `:prefix`, which is a shortcut for prefixing the component's or a custom class to the option's
  class and value. It works the same way that the `:variant` prefix does.

  The following examples are all equivalent. See Variants for more.

      defcontenttag :col, tag: :div, class: "col",
          options: [
            sm: [class: "sm", prefix: true],
          ]

      defcontenttag :col, tag: :div, class: "col",
          options: [
            sm: [class: "col-sm"],
          ]

      defcontenttag :col, tag: :div, class: "col",
          options: [
            sm: [class: "sm", prefix: "col"]
          ]

  ### Combining Options And Variants

  Combine variants and options to create complex class combinations.

  For example, in Bootstrap, `col` and `col-auto` are mutually exclusive. By combining variants and options
  you can create your desired combination.

      defcontenttag :col, tag: :div, class: "col",
          variants: [
            sm: [class: "col-sm", merge: false],    # `merge: false` removes the component class, `col`.
            auto: [class: "col-auto", merge: false]
          ],
          options: [
            sm: [class: "col-sm"],
            auto: [class: "col-auto"]
          ]

      col :auto, sm: 6 do
        "..."
      end
      #=> <div class="col-auto col-sm-6">...</div>

  Note that, options can be passed `true` to use the only the option's class rather than an explicit value.

      col auto: true do
        "..."
      end
      #=> <div class="col-auto">...</div>

  ## On Variants And Options

  While combining variants and options is powerful, sometimes it's best to go for simpliciy. The examples
  above can be declared as separate components.

      defcontenttag :col_auto, tag: :div, class: "col-auto",
          options: [
            sm: [class: "col-sm"]
            md: [class: "col-md"]
          ]

      defcontenttag :col_sm, tag: :div, class: "col-auto",
          options: [
            md: [class: "col-md"]
          ]

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
  @private_opts ExComponent.Config.get_config(:private_opts)

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
        def unquote(name)(variant, do: block) when is_atom(variant) or is_integer(variant),
          do: unquote(name)(variant, block, [])

        def unquote(name)(variant, content) when is_atom(variant) or is_integer(variant),
          do: unquote(name)(variant, content, [])

        def unquote(name)(variant, opts, do: block) do
          unquote(name)(variant, block, opts)
        end

        def unquote(name)(variant, content, opts) do
          variant = if is_atom(variant), do: variant, else: String.to_atom("#{variant}")
          render(content, [variants: [variant]] ++ opts, unquote(options))
        end
      end

      def unquote(name)(do: block), do: unquote(name)(block, [])
      def unquote(name)(content), do: unquote(name)(content, [])
      def unquote(name)(opts, do: block), do: unquote(name)(block, opts)
      def unquote(name)(content, opts), do: render(content, opts, unquote(options))
    end
  end

  defmacro defstatictag(name, options) do
    variants = Keyword.get(options, :variants)

    quote do
      if unquote(variants) do
        def unquote(name)(variant) when is_atom(variant), do: unquote(name)(variant, [])

        def unquote(name)(variant, opts) do
          variant = if is_atom(variant), do: variant, else: String.to_atom("#{variant}")
          render([variants: [variant]] ++ opts, unquote(options))
        end
      end

      def unquote(name)(), do: unquote(name)([])
      def unquote(name)(opts), do: render(opts, unquote(options))
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
          variant = if is_atom(variant), do: variant, else: String.to_atom("#{variant}")
          unquote(name)([variants: [variant]] ++ opts)
        end
      end

      def unquote(name)(), do: unquote(name)([])

      def unquote(name)(opts) do
        render_tag(opts, unquote(options))
      end
    end
  end

  @doc false
  def render_tag(opts, defaults) do
    {opts, private_opts} = merge_default_opts(opts, defaults)

    opts
    |> put_component(private_opts)
    |> put_content(:parent, opts)
  end

  @doc false
  def render(opts, defaults) do
    block = Keyword.get(defaults, :default_content, "")
    render(block, opts, defaults)
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
    default_opts = Keyword.drop(defaults, [:class, :variants, :options])

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

  defp put_content(content, option, opts) do
    opts
    |> Keyword.get(option)
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
      |> put_caller_class(opts)
      |> filter_class_list()

    opts
    |> clean_opts(private_opts)
    |> Keyword.put(:class, class)
  end

  defp filter_class_list(list) do
    list
    |> List.flatten()
    |> Enum.uniq()
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
        Enum.map(variants, fn variant ->
          private_opts
          |> get_in([:variants, variant])
          |> get_variant_class(base_class)
        end)
    end
  end

  defp get_variant_class(variant, base_class) do
    class = Keyword.get(variant, :class)

    case {
      Keyword.get(variant, :merge, true),
      Keyword.get(variant, :prefix, false)
    } do
      {true, false} ->
        [base_class, class]

      {true, true} ->
        [base_class, "#{base_class}-#{class}"]

      {true, custom} ->
        [base_class, "#{custom}-#{class}"]

      {false, false} ->
        [class]

      {false, true} ->
        ["#{base_class}-#{class}"]

      {false, custom} ->
        ["#{custom}-#{class}"]
    end
  end

  defp put_options(list, opts, private_opts) do
    base_class = Keyword.fetch!(private_opts, :class)

    class =
      private_opts
      |> Keyword.get(:variants, [])
      |> Enum.filter(fn {_name, opts} ->
        Keyword.get(opts, :option)
      end)
      |> Keyword.merge(Keyword.get(private_opts, :options, []))
      |> Enum.map(fn {name, option_opts} ->
        opts
        |> Keyword.get(name)
        |> get_option_class(option_opts, base_class)
      end)

    List.insert_at(list, -1, class)
  end

  defp get_option_class(nil, _, _), do: nil

  defp get_option_class(value, option, base_class) do
    class = Keyword.fetch!(option, :class)
    prefix = Keyword.get(option, :prefix, false)

    case {prefix, value} do
      {false, true} ->
        class

      {false, value} ->
        ~s(#{class}-#{value})

      {true, true} ->
        ~s(#{base_class}-#{class})

      {true, value} ->
        ~s(#{base_class}-#{class}-#{value})

      {prefix, true} ->
        ~s(#{prefix}-#{class})

      {prefix, value} ->
        ~s(#{prefix}-#{class}-#{value})
    end
  end

  defp put_caller_class(list, opts) do
    class = Keyword.get(opts, :class)
    List.insert_at(list, -1, class)
  end

  defp clean_opts(opts, private_opts) do
    variants =
      private_opts
      |> Keyword.get(:variants, [])
      |> Enum.filter(fn {_name, variant_opts} ->
        Keyword.get(variant_opts, :option)
      end)
      |> Keyword.keys()

    options =
      private_opts
      |> Keyword.get(:options, [])
      |> Keyword.keys()

    opts
    |> Keyword.drop(options ++ variants)
    |> Keyword.drop(@private_opts)
    |> Keyword.drop(@overridable_opts)
  end
end
