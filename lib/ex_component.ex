defmodule ExComponent do
  @moduledoc """
  This lib provides a DSL for generating HTML components.

      defcomp(:alert, variants: [:primary], class: "alert", default_tag: :div)

  This generates the follow function caluses.

      list_group :primary do
        "Alert!"
      end
      #=> <div class="alert alert-primary">Alert!</div>      

      list_group :primary, "Alert!" 
      #=> <div class="alert alert-primary">Alert!</div>

      list_group :primary class: "m-5" do
        "Alert!"
      end
      #=> <div class="alert alert-primary m-5">Alert!</div>      

      list_group :primary, "Alert!", class: "m-5"
      #=> <div class="alert alert-primary m-5">Alert!</div>

  The first argument is the component name. See below for other options.

  ## Options

  The `options` argument refers to the component options.

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

  A variant is a component modifier class. Passing a variant option
  automatically defines `component/3` arity functions for each variant.

      defcomp(:alert, class: "alert", default_tag: :div, variants: [:success])

      alert :success, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-success extra">Alert!</div>

      alert :success, "Alert!", class: "extra"
      #=> <div class="alert alert-success extra">Alert!</div>

  ### Blocks

  The `block` options controls the generation of function clauses.

  When `true`, the default, it generates the following function clauses.

      defcomp(:alert, class: "alert", default_tag: :div)

      alert do
        "Content"
      end
      #=> <div class="alert">Content</div>

      alert class: "text-right" do
        "Content"
      end
      #=> <div class="alert text-right">Content</div>

  If the component has defined variants, an component/3 function clause
  for each variant is defined.

      defcomp(:alert, class: "alert", default_tag: :div, variants: [:success])

      alert :success do
        "Content"
      end
      #=> <div class="alert alert-success">Content</div>

      alert :success, class: "text-right" do
        "Content"
      end
      #=> <div class="alert alert-success text-right">Content</div>

  Sometimes, it's useful to generate function clauses that only accept blocks. You can
  use the `block: :only` option for that.

      defcomp(:card_text, block: :only, class: "card-text", default_tag: :p)

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
