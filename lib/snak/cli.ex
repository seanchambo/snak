defmodule Snik.CLI do
  def main(_args) do
    # GenServer.start_link(Snik.Game, [], name: Game)
    # GenServer.start_link(Snik.IO, [], name: IO)

    :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
