defmodule ExComponent.Config do
  @moduledoc """
  Contains configuration options

  - `component_opts` A list of options passed to the component that should be dropped before being passed to the HTML.

  """

  @config %{
    component_opts: ~w[tag variants delegate dismissable]a
  }

  def get_config(key), do: @config[key]
end
