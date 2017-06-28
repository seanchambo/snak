defmodule Snak do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Snak.Game, []),
      worker(Snak.IO, [])
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end

defmodule Snak.CLI do
  def main(_args) do
    :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
