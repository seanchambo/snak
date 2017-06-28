defmodule Snak.Mixfile do
  use Mix.Project

  def project do
    [app: :snak,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: escript()]
  end

  def application do
    [applications: [],
     mod: {Snak, []}]
  end

  defp escript do
    [main_module: Snak.CLI,
     emu_args: "-noinput -elixir ansi_enabled true"]
  end
end
