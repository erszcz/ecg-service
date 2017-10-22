defmodule EcgService.Mixfile do
  use Mix.Project

  def project do
    [app: :ecg_service,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {EcgService, []}]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:ecg, github: "erszcz/ecg", ref: "a03db02"}]
  end
end
