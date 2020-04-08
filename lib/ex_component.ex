defmodule ExComponent do
  @moduledoc """
  This lib provides a DSL for generating HTML components.

      defcomp(:alert, arity: 3, class: "alert", default_tag: :div, variants: [:primary, :info])

  This generates the follow function caluses.

      list_group :info, "Alert!" 
      #=> <div class="alert alert-info">Alert!</div>

      list_group :info, "Alert!", class: "m-5"
      #=> <div class="alert alert-info m-5">Alert!</div>

      list_group :info do
        "Alert!"
      end
      #=> <div class="alert alert-info">Alert!</div>      

      list_group :info class: "m-5" do
        "Alert!"
      end
      #=> <div class="alert alert-info m-5">Alert!</div>      

  The first argument is the component name. See below for other options.

  ## Options

  The `options` argument refers to the component options.

    - `arity` The component function arity. Defaults to `2`.
    - `class` The component CSS class name. Required.
    - `default_tag` The component HTML tag. Required.
    - `delegate` The function to delegate rendering to. Defaults to `Phoenix.HTML.Tag.content_tag/3`.
    - `html_opts` A list of opts that will be forwarded to the HTML.
    - `prepend` Any content to prepend before the component.
    - `variants` A list of component variants.

  See below for a detailed explanation of each option.

  ### Class

  The `class` is the base class of the component. It is also used to build
  variant classes in the form `class="{class class-variant}"`.

  ### Default Tag

  The `default_tag` sets the default tag to use when building the component. The
  default tag can be overriden by calling the function with a `tag` option.

  ### Variants

  A variant is a component modifier class, like `success`.

      <div class="alert alert-success">Success!</div>

  Variants must be declared at the component level to work.

      defcomp(:alert, class: "alert", default_tag: :div, variants: [:info, :success])

  Use variants by passing the `variant` option. You can pass a list of variants.

      list_group_item tag: :a, variant: [:success, :action] ..
      #=> <a class="list-group-item list-group-item-success list-group-item-action"> ...

  ### Arity and Blocks

  The `arity` and `block` options control the generation of function clauses.

  Use `arity: 2` to generate function clauses that accept content and
  an options list.

      defcomp(:card_text, arity: 2, class: "card-text", default_tag: :p)

      card_text "Content"
      #=> <p class="card-text">Content</p>
    
      card_text "Content", class: "text-right"
      #=> <p class="card-text text-right">Content</p>

  The `block` option, which defaults to `true`, generates the following block clauses.

      card_text do
        "Content"
      end
      #=> <p class="card-text">Content</p>

      card_text class: "text-right" do
        "Content"
      end
      #=> <p class="card-text text-right">Content</p>

  You can disable block clauses using `block: false`.

      defcomp(:card_text, arity: 2, block: false, class: "card-text", default_tag: :p)

  Sometimes, it's useful to generate function clauses that only accept blocks. You can
  use the `block: :only_block` option for that.

      defcomp(:card_text, arity: 2, block: :only_block, class: "card-text", default_tag: :p)

  This is useful for components that nest other components but do not have
  their own content, like `card`.

      card do
        card_header ...
      end
      #=> <div class="card">...</div>

      card class: "bg-white" do
        "Content"
      end
      #=> <div class="card bg-white">Content</div>

  The `arity: 3` option generates components that accept a variant as the first argument.

      defcomp(:card_text, arity: 3, class: "card-text", default_tag: :p)

      badge :primary, "Content"
      #=> <span class="card-text text-right">Content</span>

      badge :primary, "Content", class: "float-right"
      #=> <span class="card-text float-right">Content</span>

      badge :primary do
        "Content"
      end
      #=> <span class="card-text float-right">Content</span>

      badge :primary, class: "float-right" do
        "Content"
      end
      #=> <span class="card-text float-right">Content</span>

  The `block` option is always `true` when using `arity: 3`.

  ### Prepending Content

  Use the `prepend` option to prepend other components. This is useful for
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

  ### Function Delegation

  Pass a function capture to the `delegate` option to forward execution to
  another function. This is useful for generating tags using `Phoenix.HTML`.

      defcomp(:card_image, class: "card-img", delegate: &Phoenix.HTML.Tag.img_tag/2)

      card_image "path", class: "extra"
      #=> <img src="path" class="card-image extra">

  ### HTML Options

  The option is `html_opts` is forwarded onto the underlying HTML. Any keys can be
  overriden during function calls.

      defcomp(:alert, arity: 3, class: "alert", default_tag: :div, html_opts: [role: :alert])

    #=> <div class="alert" role="alert"></div>

  """
  defmacro defcomp(name, options) do
    quote do
      case Keyword.get(unquote(options), :arity, 2) do
        2 ->
          case Keyword.get(unquote(options), :block, true) do
            true ->
              def unquote(name)(do: block), do: unquote(name)([], do: block)

              def unquote(name)(opts, do: block) do
                render(opts, unquote(options), do: block)
              end

              def unquote(name)(text), do: unquote(name)(text, [])

              def unquote(name)(text, opts) do
                render(opts, unquote(options), do: text)
              end

            :only ->
              def unquote(name)(do: block), do: unquote(name)([], do: block)

              def unquote(name)(opts, do: block) do
                render(opts, unquote(options), do: block)
              end

            false ->
              def unquote(name)(text), do: unquote(name)(text, [])

              def unquote(name)(text, opts) do
                render(opts, unquote(options), do: text)
              end
          end

        3 ->
          case Keyword.get(unquote(options), :block, true) do
            true ->
              def unquote(name)(variant, do: block), do: unquote(name)(variant, [], do: block)

              def unquote(name)(variant, opts, do: block) do
                render([variant: variant] ++ opts, unquote(options), do: block)
              end

              def unquote(name)(variant, text), do: unquote(name)(variant, text, [])

              def unquote(name)(variant, text, opts) when is_binary(text) do
                render([variant: variant] ++ opts, unquote(options), do: text)
              end

            :only ->
              def unquote(name)(variant, do: block), do: unquote(name)(variant, [], do: block)

              def unquote(name)(variant, opts, do: block) do
                render([variant: variant] ++ opts, unquote(options), do: block)
              end
          end
      end
    end
  end

  @doc """
  Generates a component. Accepts a list of options, which is passed
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
      if prepend = Keyword.get(options, :prepend) do
        [prepend, block]
      else
        block
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
    |> Keyword.get(:delegate, Keyword.get(options, :delegate))
    |> case do
      nil ->
        &Phoenix.HTML.Tag.content_tag/3

      func ->
        func
    end
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
