defmodule ExComponent do
  @moduledoc """
  This lib provides a DSL for generating HTML components.

      defcomp :alert, type: {:content_tag, :div}, variants: [:primary, :success], class: "alert"

      alert "Alert!"
      #=> <div class="alert">Alert!</div>      

      alert :primary, "Alert!"
      #=> <div class="alert alert-primary">Alert!</div>

      alert :success, "Alert!"
      #=> <div class="alert alert-success">Alert!</div>

      alert :success, "Alert!", class: "extra"
      #=> <div class="alert alert-success extra">Alert!</div>

  Generated function clauses accept a block and a list of opts.

      alert do
        "Alert!"
      end
      #=> <div class="alert">Alert!</div>

      alert class: "extra" do
        "Alert!"
      end
      #=> <div class="alert extra">Alert!</div>

      alert :primary do
        "Alert!"
      end
      #=> <div class="alert alert-primary extra">Alert!</div>

  ## Options

    * `:class` - the component's class name. This option is required.

    * `:html_opts` - a list of opts to forward onto the HTML.

    * `:parent` - wraps the component in the given option. The option can be a function that generates another component or an atom HTML tag name.

    * `:prepend` - prepends the given content to the component. Can be a function that generates another component or an atom of a self-closing HTML tag.

    * `:append` - appends the given content to the component. Can be a function that generates another component or an atom of a self-closing HTML tag.

    * `:variants` - a list of component variants. Each variant generates a `component/3` function clause where an atom variant name is the first argument.

  The `:class` is the base class of the component and is used to build
  variant classes in the form `class="{class class-variant}"`.

  The `:variants` option adds a modifier class to the component and automatically
  generates `component/3` function clauses for each variant, where the variant is the
  first argument.

      defcomp :alert, type: {:content_tag, :div}, class: "alert", variants: [:success]

      alert :success, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-success extra">Alert!</div>

  For components that can have multiple variants, use `component/2` and
  pass a list to the `:variant` option.

      defcomp :list_group, type: {:content_tag, :ul}, class: "list-group", variants: [:flush, :horizontal]

      list_group variant: [:flush, :horizontal], class: "extra" do
        "..."
      end
      #=> <div class="list-group list-group-flush list-group-horizontal ">...</div>

  ## Appending And Prepending Content

  The `:append` and `:prepend` options are useful adding additional content the component's HTML.

  For example, an an alert component that has a close button.

    defcomp :close_button, type: {content_tag, :button}, class: "close", data: [dismiss: "alert"], aria: [label: "Close"]
    defcomp :alert, type: {content_tag, :div}, class: "alert", prepend: &{&close_button/2, "&nbsp;"}, variants: [:primary]

    alert :primary do
      "Content"
    end
    #=> <div class="alert alert-primary">
          <button aria-label=\"Close\" class=\"close\" data-dismiss=\"alert\">
            <span>&times;</span>
          </button>
          Content
        </div>

  You can pass an atom or an anonymous function.

      defcomp :alert, ..., prepend: :hr
      defcomp :alert, ..., prepend: &hr/1

  You can also pass a tuple with a tag or an anonymous function, content and/or options.

      defcomp :alert, ..., prepend: {:hr, class: "divider"}

      defcomp :alert, ..., prepend: {:button, "&nbsp;"}
      defcomp :alert, ..., prepend: {:button, "&nbsp;", class: "close"}

      defcomp :alert, ..., prepend: {&button/2, "&nbsp;"}
      defcomp :alert, ..., prepend: {&button/3, "&nbsp;", class: "close"}

  ## Nesting Components

  The `:parent` option allows you to compose components. This can be useful to nest a component
  in another or wrap its content in an additional tag.

  You can pass an atom, a function, or a tuple with either a function or an atom, and a
  list of parent options.

  For example, breadcrumbs in Bootstrap are built with an `ol` tag wrapped in a `nav` tag.

      <nav role="nav">
        <ol class="breadcrumbs">
          <li class="breadcrumbs-item">...</li>
        </ol>
      </nav>

  You can use the `parent: :nav` and `parent: {:nav, [role: "nav"]}` to address this case.

      defcomp :breadcrumbs, type: {:content_tag, :ol}, ..., parent: :nav
      defcomp :breadcrumbs, type: {:content_tag, :ol}, ..., parent: {:nav, [role: "nav"]}

  Another example is the Bootstrap close button, whose content is wrapped in a span.

      <button aria-label=\"Close\" class=\"close\" data-dismiss=\"alert\">
        <span>&times;</span>
      </button>

      defcomp :button, type: {:content_tag, :button}, ...
      defcomp :close_button, type: {:content_tag, :span}, ..., parent: {&button/2, [data: [dismiss: "alert"]]}

      close_button("&nbsp;")

  ## Function Delegation

  Pass a function capture to the `:delegate` option to forward execution to
  another module. This is useful for generating tags using `Phoenix.HTML`.

      defcomp :card_image, type: {:delegate, &Phoenix.HTML.Tag.img_tag/2}, class: "card-img"

      card_image "path", class: "extra"
      #=> <img src="path" class="card-image extra">

  ## HTML Options

  All `:html_opts` are forwarded onto the underlying HTML. Any keys can be
  overriden during function calls.

      defcomp :alert, type: {:content_tag, :div}, class: "alert", html_opts: [role: :alert]

      alert "Alert!"
      #=> <div class="alert" role="alert">Alert!</div>

  """
  import Phoenix.HTML.Tag, only: [tag: 1, tag: 2, content_tag: 2, content_tag: 3]

  defmacro defcomp(name, options) do
    variants = Keyword.get(options, :variants)
    type = Keyword.fetch!(options, :type)

    quote do
      case unquote(type) do
        {type, name} when type in [:content_tag, :delegate] ->
          if unquote(variants) do
            def unquote(name)(variant, do: block) when is_atom(variant) do
              unquote(name)([variants: variant], do: block)
            end

            def unquote(name)(variant, opts, do: block) when is_atom(variant) do
              unquote(name)([variants: variant] ++ opts, do: block)
            end

            def unquote(name)(variant, content) when is_binary(content) do
              unquote(name)([variants: variant], do: content)
            end

            def unquote(name)(variant, content, opts) when is_binary(content) do
              unquote(name)([variants: variant] ++ opts, do: content)
            end
          end

          def unquote(name)(do: block), do: unquote(name)([], do: block)

          def unquote(name)(opts, do: block) do
            render(unquote(type), opts, unquote(options), block)
          end

          def unquote(name)(content), do: unquote(name)(content, [])

          def unquote(name)(content, opts) do
            render(unquote(type), opts, unquote(options), content)
          end

        {:tag, name} ->
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
            render(unquote(type), opts, unquote(options))
          end
      end
    end
  end

  @doc """
  Generates a HTML component. Accepts a list of options that is passed
  onto the underlying HTML.

  The `options` argument refers to the component options. See @moduledoc
  for details.

  Variants they must be registered in the component definition to work.

  ## Possible Types

    + `{:tag, tag_name}` - generates a void HTML tag that does not accept content. For exmaple, `br` and `hr`.

    + `{:content_tag, tag_name}` - generates an HTML tags that accepts content. For example, `div` and `ul`.

    + `{:delegate, &function/2}` - delegates processing to the given function.

  ## Options

    + `:tag` - overrides the given tag in the `:type` component option.

    + `:class` - additional CSS classes to append to the `:class` component option.

    + `:append` - overrides the component's `:append` option in @moduledoc.

    + `:prepend` - overrides the component's `:prepend` option in @moduledoc.

    + `:variant` - an atom or a list of atom variants.

  """
  def render({:tag, name}, opts, options) do
    tag = Keyword.get(opts, :tag, name)
    opts = process_opts(opts, options)
    tag(tag, opts)
  end

  def render({:content_tag, name}, opts, options, content) do
    tag = Keyword.get(opts, :tag, name)

    content =
      opts
      |> get_siblings(options)
      |> put_siblings(content)

    opts = process_opts(opts, options)

    put_content({tag, content, opts}, options)
  end

  def render({:delegate, fun}, opts, options, content) do
    content =
      opts
      |> get_siblings(options)
      |> put_siblings(content)

    opts = process_opts(opts, options)

    put_content({fun, content, opts}, options)
  end

  defp get_siblings(opts, options) do
    opts
    |> Keyword.take([:append, :prepend])
    |> case do
      [] ->
        Keyword.take(options, [:append, :prepend])

      siblings ->
        siblings
    end
  end

  defp put_siblings(siblings, content) do
    siblings
    |> Enum.reduce([content], fn {name, sibling}, acc ->
      case name do
        :prepend ->
          [get_sibling(sibling) | acc]

        :append ->
          [acc | get_sibling(sibling)]
      end
    end)
  end

  defp get_sibling(tag) when is_atom(tag), do: tag(tag)
  defp get_sibling(fun) when is_function(fun), do: fun.()

  defp get_sibling({tag, opts}) when is_atom(tag) and is_list(opts), do: tag(tag, opts)
  defp get_sibling({fun, opts}) when is_function(fun) and is_list(opts), do: fun.(opts)

  defp get_sibling({tag, content}) when is_atom(tag) and is_binary(content),
    do: content_tag(tag, content)

  defp get_sibling({fun, content}) when is_function(fun) and is_binary(content), do: fun.(content)

  defp get_sibling({tag, content, opts}) when is_atom(tag), do: content_tag(tag, content, opts)
  defp get_sibling({fun, content, opts}) when is_function(fun), do: fun.(content, opts)

  defp put_content({tag, content, opts}, options) do
    content =
      if is_function(tag) do
        tag.(content, opts)
      else
        content_tag(tag, content, opts)
      end

    case Keyword.get(options, :parent) do
      nil ->
        content

      parent when is_atom(parent) ->
        content_tag(parent, content, [])

      {parent, parent_opts} when is_atom(parent) ->
        content_tag(parent, content, parent_opts)

      fun when is_function(fun) ->
        fun.(content, [])

      {fun, parent_opts} when is_function(fun) ->
        fun.(content, parent_opts)
    end
  end

  defp process_opts(opts, options) do
    opts
    |> merge_default_html_opts(options)
    |> put_class(options)
    |> drop_opts()
  end

  defp merge_default_html_opts(opts, options) do
    default_html_opts = Keyword.get(options, :html_opts, [])

    opts
    |> Keyword.merge(default_html_opts, fn _k, opt_value, default_value ->
      opt_value || default_value
    end)
  end

  defp put_class(opts, options) do
    base_class = Keyword.fetch!(options, :class)
    user_class = Keyword.get(opts, :class)

    variant_list = Keyword.get(options, :variants)

    class_list =
      opts
      |> put_variant_class(base_class, variant_list)
      |> put_user_class(user_class)
      |> Enum.join(" ")

    Keyword.put(opts, :class, class_list)
  end

  defp put_variant_class(_opts, base_class, nil), do: [base_class]

  defp put_variant_class(opts, base_class, variants) do
    opts
    |> Keyword.get_values(:variants)
    |> List.flatten()
    |> Enum.filter(fn variant ->
      variant in variants
    end)
    |> Enum.map(fn value ->
      ~s(#{base_class}-#{value})
    end)
    |> List.insert_at(0, base_class)
  end

  defp put_user_class(opts, nil), do: opts
  defp put_user_class(opts, user_class), do: opts ++ [user_class]

  defp drop_opts(opts) do
    ex_bs_component_opts = ExComponent.Config.get_config(:component_opts)
    Keyword.drop(opts, ex_bs_component_opts)
  end
end
