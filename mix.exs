defmodule YamlEncoder.Mixfile do
  use Mix.Project

  def project do
    [app: :yaml_encoder,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.11", only: :dev},
     {:earmark, "~> 0.1", only: :dev},
     {:dialyxir, "~> 0.3", only: [:dev]}]
  end

  defp description do
    """
    Simple module to encode data to YAML.
    Not ready for production, still WIP.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Andrea Franz"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pilu/yaml_encoder",
        "Docs" => "http://hexdocs.pm/yaml_encoder/"}
    ]
  end
end
