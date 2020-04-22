defmodule ExComponent.Config do
  @moduledoc """
  Contains configuration options.

  + `component_opts` - a list of options passed to the component function call that should be dropped before being passed to the HTML.

  """

  @config %{
    overridable_opts: ~w[append tag parent prepend wrap_content]a
  }

  def get_config(key), do: @config[key]
end
