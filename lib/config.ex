defmodule ExComponent.Config do
  @moduledoc """
  Contains configuration options.

  + `overridable_opts` - a list of default component options that can be overridden during function calls.

  """

  @config %{
    overridable_opts: ~w[append tag parent prepend wrap_content]a,
    private_opts: ~w[variants merge prefix]a
  }

  def get_config(key), do: @config[key]
end
