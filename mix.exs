defmodule ExComponent.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_component,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "ExComponent",
      description:
        "A DSL for building dynamic and reusable components in EEx for any frontend framework.",
      source_url: "https://github.com/abitdodgy/ex_component"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 2.10"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/abitdodgy/ex_component"}
    ]
  end
end
