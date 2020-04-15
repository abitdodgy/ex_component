defmodule ExComponent do
  @moduledoc """
  This lib provides a DSL for generating HTML components.

      defcomp(:alert, type: {:content_tag, :div}, variants: [:primary, :success], class: "list-group")

      alert "Alert!"
      #=> <div class="alert">Alert!</div>      

      alert :primary, "Alert!"
      #=> <div class="alert alert-primary">Alert!</div>      

      alert :success, "Alert!"
      #=> <div class="alert alert-success">Alert!</div>    

      alert :success, "Alert!", class: "extra"
      #=> <div class="alert alert-success extra">Alert!</div>    

  All generated function clauses accept a block, and a list of opts that
  is forwarded onto the HTML.

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

  See below for an explanation of the options.

  ## Options

    * `:class` - the component's class name. This option is required.

    * `:html_opts` - a list of opts to forward onto the HTML.

    * `:nest` - nests the component in the given option. This option can be a function that generates another component or an atom HTML tag name.

    * `:prepend` - prepends the given content to the component. Can be a function that generates another component or an atom of a self-closing HTML tag.

    * `:append` - appends the given content to the component. Can be a function that generates another component or an atom of a self-closing HTML tag.

    * `:variants` - a list of component variants. Each variant generates a `component/3` function clause.

  The `:class` is the base class of the component and is used to build
  variant classes in the form `class="{class class-variant}"`.

  The `:variants` option adds a modifier class to the component and automatically
  generates `component/3` function clauses for each variant, where the variant is the
  first argument.

      defcomp(:alert, type: {:content_tag, :div}, class: "alert", variants: [:success])

      alert :success, class: "extra" do
        "Alert!"
      end
      #=> <div class="alert alert-success extra">Alert!</div>

  For components that can have multiple variants, use `component/2` and
  pass a list to the `:variant` option.

      defcomp(:list_group, type: {:content_tag, :ul}, class: "list-group", variants: [:flush, :horizontal])

      list_group variant: [:flush, :horizontal], class: "extra" do
        "..."
      end
      #=> <div class="list-group list-group-flush list-group-horizontal ">...</div>

  ## Appending And Prepending Content

  Use the `:append` and `:prepend` option to prepend or append other components to the component's
  content. For example, an an alert that has a close button.

    defcomp(:alert, type: {content_tag, :div}, class: "alert", prepend: close_button(), variants: [:primary])

    alert :primary do
      "Content"
    end
    #=> <div class="alert alert-primary">
          <button aria-label=\"Close\" class=\"close\" data-dismiss=\"alert\">
            <span>&times;</span>
          </button>
          Content
        </div>

  You can pass an atom that will be forwarded onto `Phoenix.HTML.Tag/1`.

      defcomp(:alert, type: {content_tag, :div}, class: "alert", prepend: :hr, variants: [:primary])

  ## Nesting Components

  The `:nest` option allows you to nest the component in another tag.

  This option is useful for wrapping components in parent tags. For example, breadcrumbs
  in Bootstrap are built with an `ol` tag wrapped in a `nav` tag.

      defcomp(:breadcrumbs, type: {:content_tag, :ol}, ..., nest: nav())
      defcomp(:breadcrumbs, type: {:content_tag, :ol}, ..., nest: :nav)

  ## Function Delegation

  Pass a function capture to the `:delegate` option to forward execution to
  another module. This is useful for generating tags using `Phoenix.HTML`.

      defcomp(:card_image, type: {:delegate, &Phoenix.HTML.Tag.img_tag/2}, class: "card-img")

      card_image "path", class: "extra"
      #=> <img src="path" class="card-image extra">

  ## HTML Options

  All `:html_opts` are forwarded onto the underlying HTML. Any keys can be
  overriden during function calls.

      defcomp(:alert, type: {:content_tag, :div}, class: "alert", html_opts: [role: :alert])

      alert "Alert!"
      #=> <div class="alert" role="alert">Alert!</div>

  """
  import Phoenix.HTML.Tag, only: [tag: 1, tag: 2, content_tag: 3]

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
            render(unquote(type), opts, unquote(options), do: block)
          end

          def unquote(name)(content), do: unquote(name)(content, [])

          def unquote(name)(content, opts) do
            render(unquote(type), opts, unquote(options), do: content)
          end

        {:tag, name} ->
          if unquote(variants) do
            def unquote(name)(variant) when is_atom(variant) do
              unquote(name)([variants: variant])
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
  Generates a HTML component. Accepts a list of options, which is passed
  onto the underlying HTML.

  The `options` argument refers to the component options. See moduledoc
  for details.

  Note that, for variants to work, they must be registered in the component.

  ## Possible Types

    + `{:tag, tag_name}` generates void HTML tags, those that do not accept content. For example, `hr`
    + `{:content_tag, tag_name}` generates HTML tags that accept their own content
    + `{:delegate, &function/2}` delegates processing to another function

  ## Options

    + `:tag` - overrides the `default_tag` in component options
    + `:class` - additional CSS classes to append to the `class` component option
    + `:variant` - an atom or a list of atom component variants

  """
  def render({:tag, name}, opts, options) do
    opts = put_opts(opts, options)
    tag(name, opts)
  end

  def render({:content_tag, name}, opts, options, do: block) do
    opts = put_opts(opts, options)
    block = put_siblings(options, block)
    content_tag(name, block, opts)
  end

  def render({:delegate, fun}, opts, options, do: block) do
    opts = put_opts(opts, options)
    block = put_siblings(options, block)
    fun.(block, opts)
  end

  defp put_opts(opts, options) do
    opts
    |> merge_default_html_opts(options)
    |> put_class(options)
    |> drop_options()
  end

  defp put_siblings(options, content) do
    options
    |> Keyword.take([:prepend, :append])
    |> Enum.reduce([content], fn {sibling, tag_or_content}, acc ->
      case sibling do
        :prepend ->
          [put_sibling(tag_or_content) | acc]

        :append ->
          [acc | put_sibling(tag_or_content)]
      end
    end)
  end

  defp put_sibling(tag) when is_atom(tag), do: tag(tag)
  defp put_sibling(content), do: content

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

  defp merge_default_html_opts(opts, options) do
    opts
    |> Keyword.merge(Keyword.get(options, :html_opts, []))
  end

  defp drop_options(opts) do
    ex_bs_component_opts = ExComponent.Config.get_config(:component_opts)
    Keyword.drop(opts, ex_bs_component_opts)
  end
end
