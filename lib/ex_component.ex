defmodule ExComponent do
  @moduledoc """
  This lib provides a DSL for generating HTML components.

      defcomp(:alert, variants: [:primary, :success], class: "list-group", default_tag: :div)

      alert "Alert!"
      #=> <div class="alert">Alert!</div>      

      alert :primary, "Alert!"
      #=> <div class="alert alert-primary">Alert!</div>      

      alert :success, "Alert!"
      #=> <div class="alert alert-success">Alert!</div>      

  Notice that a `component/2` clause is generated for the base component, and
  a `component/3` clause for each variant.

  All generated function clauses accept a block, and a list of opts that
  is forwarded onto the HTML.

      alert class: "extra" do
        "Alert!"
      end
      #=> <div class="alert extra">Alert!</div>

      alert :primary do
        "Alert!"
      end
      #=> <div class="alert alert-primary">Alert!</div>

      alert :primary, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-primary extra">Alert!</div>

      alert :primary, "Alert!", class: "extra"
      #=> <div class="alert alert-primary extra">Alert!</div>

  See below for an explanation of the options.

  ## Options

    * `:class` - the component's class name. This option is required.

    * `:block` - when `true`, generates an additional block syntax for each function clause. When `:only`, generates only block syntax for each function clause. Use `false` to disable block generation. Defaults to `true`.

    * `:default_tag` - the component's HTML tag. This option is required.

    * `:delegate` - delegates rendering to the given function. Defaults to `&Phoenix.HTML.Tag.content_tag/3`.
    
    * `:html_opts` - a list of opts to forward onto the HTML.

    * `:nest` - nests the component in the given option. This option can be a function that generates another component or an atom HTML tag name.

    * `:prepend` - prepends the given content to the component. Can be a function that generates another component or an atom of a self-closing HTML tag.

    * `:variants` - a list of component variants. Each variant generates a `component/3` function clause.

  The `:class` is the base class of the component and is used to build
  variant classes in the form `class="{class class-variant}"`.

  The `:default_tag` sets the default tag to use when building the component. It can
  be overriden by passing the `:tag` option during function calls.

  The `:variants` option adds a modifier class to the component and automatically
  generates `component/3` function clauses for each variant, where the variant is the
  first argument.

      defcomp(:alert, class: "alert", default_tag: :div, variants: [:success])

      alert :success, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-success extra">Alert!</div>

  For components that can have multiple variants, use `component/2` and
  pass a list to the `:variant` option.

      defcomp(:list_group, class: "list-group", default_tag: :div, variants: [:flush, :horizontal])

      list_group variant: [:flush, :horizontal], class: "extra" do
        "..."
      end
      #=> <div class="list-group list-group-flush list-group-horizontal ">...</div>

  ## Blocks

  The `:block` option defaults to `true` and generates additional block syntax clauses for each function.

      defcomp(:alert, block: true, ...)

      alert "Alert!"
      #=> <div class="alert">Alert!</div>

      alert do: "Alert!"
      #=> <div class="alert">Alert!</div>

  Pass `:only` to generate only block clauses, which is useful for components
  that nest other components but do not have their own content, like `card`.

      defcomp(:card, block: :only, ...)

      card do: card_header(...)
      #=> <div class="card">...</div>

      card card_header(...)
      ** FunctionClauseError ...

  Pass `false` to disable block clause generation.

      defcomp(:card, block: :false, ...)

      card do: card_header(...)
      ** FunctionClauseError ...

      card card_header(...)
      #=> <div class="card">...</div>

  ## Prepending Content

  Use the `:prepend` option to prepend other components. This is useful for
  alerts that can have a close button.

    defcomp(:alert, arity: 3, class: "alert", default_tag: :div, prepend: close_button(role: :alert), variants: [:primary])

    alert :primary do
      "Content"
    end
    #=> <div class="alert alert-primary">
          <button aria-label=\"Close\" class=\"close\" data-dismiss=\"alert\">
            <span>&times;</span>
          </button>
          Content
        </div>

  If you pass an atom it will be forwarded to `Phoenix.HTML.Tag/1`. You can pass safe
  content, like the result of a function call to another component.

  ## Nesting Components

  The `:nest` option allows you to nest the component in the given content. When given a tag name,
  it is forwarded onto `Phoenix.HTML.Tag.content_tag/3`. You can also use function
  calls to generate other components.

  This option is useful for wrapping components in parent tags. For example, breadcrumbs
  in Bootstrap are built with an `ol` tag wrapped in a `nav` tag.

      defcomp(:breadcrumbs, default_tag: :ol, ..., nest: nav())
      defcomp(:breadcrumbs, default_tag: :ol, ..., nest: :nav)

  ## Function Delegation

  Pass a function capture to the `:delegate` option to forward execution to
  another module. This is useful for generating tags using `Phoenix.HTML`.

      defcomp(:card_image, class: "card-img", delegate: &Phoenix.HTML.Tag.img_tag/2)

      card_image "path", class: "extra"
      #=> <img src="path" class="card-image extra">

  ## HTML Options

  All `:html_opts` are forwarded onto the underlying HTML. Any keys can be
  overriden during function calls.

      defcomp(:alert, arity: 3, class: "alert", default_tag: :div, html_opts: [role: :alert])

      #=> <div class="alert" role="alert"></div>

  """
  import Phoenix.HTML.Tag, only: [tag: 1, content_tag: 3]

  defmacro defcomp(name, options) do
    quote do
      if Keyword.get(unquote(options), :variants) do
        def unquote(name)(variant, do: block) when is_atom(variant) do
          unquote(name)([variant: variant], do: block)
        end

        def unquote(name)(variant, opts, do: block) when is_atom(variant) do
          unquote(name)([variant: variant] ++ opts, do: block)
        end

        unless Keyword.get(unquote(options), :block) == :only do
          def unquote(name)(variant, content) when is_binary(content) do
            unquote(name)([variant: variant], do: content)
          end

          def unquote(name)(variant, content, opts) when is_binary(content) do
            unquote(name)([variant: variant] ++ opts, do: content)
          end
        end
      end

      if Keyword.get(unquote(options), :block, true) do
        def unquote(name)(do: block), do: unquote(name)([], do: block)

        def unquote(name)(opts, do: block) do
          render(opts, unquote(options), do: block)
        end
      end

      unless Keyword.get(unquote(options), :block) == :only do
        def unquote(name)(content), do: unquote(name)(content, [])

        def unquote(name)(content, opts) do
          render(opts, unquote(options), do: content)
        end
      end
    end
  end

  @doc """
  Generates HTML content. Accepts a list of options, which is passed
  onto the underlying HTML.

  The `options` argument refers to the component options. See moduledoc
  for details.

  Note that, for variants to work, they must be registered in the component.

  ## Options

    - `tag` Overrides the `default_tag` in component options
    - `class` Additional CSS classes to append to the `class` component option
    - `delegate` Forwards executing to the given function
    - `variant` An atom or a list of atom component variants

  """
  def render(opts, options, do: block) when is_list(opts) do
    tag = Keyword.get(opts, :tag, Keyword.get(options, :default_tag))
    fun = get_function(opts, options)

    block =
      case Keyword.get(options, :prepend) do
        nil ->
          block

        tag when is_atom(tag) ->
          [tag(tag), block]

        content ->
          [content, block]
      end

    opts =
      opts
      |> put_variants(options)
      |> put_class(options)
      |> merge_default_options(options)
      |> drop_options()

    fun
    |> :erlang.fun_info()
    |> Keyword.get(:arity)
    |> case do
      3 ->
        fun.(tag, opts, do: block)

      arity when arity in [1, 2] ->
        fun.(block, opts)
    end
  end

  defp put_variants(opts, options) do
    variants =
      if variants_list = Keyword.get(options, :variants, []) do
        opts
        |> Keyword.take([:variant])
        |> Keyword.values()
        |> List.flatten()
        |> Enum.filter(fn variant ->
          variant in variants_list
        end)
      end

    Keyword.put(opts, :variant, variants)
  end

  defp merge_default_options(opts, options) do
    opts
    |> Keyword.merge(Keyword.get(options, :html_opts, []))
  end

  defp get_function(opts, options) do
    opts
    |> Keyword.get(:delegate, Keyword.get(options, :delegate, &content_tag/3))
  end

  defp put_class(opts, options) do
    base_class = Keyword.fetch!(options, :class)
    user_class = Keyword.get(opts, :class)

    class_list =
      opts
      |> Keyword.get(:variant)
      |> Enum.map(fn value ->
        "#{base_class}-#{value}"
      end)
      |> put_base_class(base_class)
      |> put_user_class(user_class)
      |> Enum.join(" ")

    Keyword.put(opts, :class, class_list)
  end

  defp put_base_class(opts, base_class), do: [base_class] ++ opts

  defp put_user_class(opts, nil), do: opts
  defp put_user_class(opts, user_class), do: opts ++ [user_class]

  defp drop_options(opts) do
    ex_bs_component_opts = ExComponent.Config.get_config(:component_opts)
    Keyword.drop(opts, ex_bs_component_opts)
  end
end
