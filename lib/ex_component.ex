defmodule ExComponent do
  @moduledoc false

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

        def unquote(name)(variant, opts, do: block) when is_atom(variant) do
          unquote(name)(variant, block, opts)
        end

        def unquote(name)(variant, content, opts) when is_atom(variant) do
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

    + `:parent` - wraps the component in the given tag.

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

  def make(name), do: make(name, [])
  def make(name, opts) when is_list(opts), do: tag(name, opts)
  def make(name, content), do: make(name, content, [])
  def make(name, content, opts) when is_list(opts), do: content_tag(name, content, opts)

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
      child = apply(__MODULE__, :make, Tuple.to_list(child))

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
    |> make(opts)
  end

  defp put_component(content, opts, defaults) do
    opts = put_class(opts, defaults)

    defaults
    |> Keyword.get(:tag)
    |> make(content, opts)
  end

  defp put_parent(content, opts) do
    case Keyword.get(opts, :parent) do
      nil ->
        content

      {name, opts} ->
        make(name, content, opts)
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
