defmodule Snak.IO do
  use GenServer

  alias IO.ANSI
  alias Snak.Game

  def start_link, do: GenServer.start_link(__MODULE__, [], name: IO)

  def init(_args) do
    print(:start_screen, %{})
    {:ok, Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])}
  end

  def print_mode(mode, game),   do: print(mode, game)
  def move_cursor(row, col),    do: ANSI.format ["\e[#{round(row)};#{round(col)}f"]

  def handle_info({pid, {:data, data}}, pid) do
    case interpret_event(data) do
      :space -> Game.start()
      :pause -> Game.pause()
      direction when direction in [:up, :down, :left, :right] -> Game.direction(direction)
      _ -> nil
    end

    {:noreply, pid}
  end

  defp interpret_event(" "),    do: :space
  defp interpret_event("p"),    do: :pause
  defp interpret_event("w"),    do: :up
  defp interpret_event("s"),    do: :down
  defp interpret_event("d"),    do: :right
  defp interpret_event("a"),    do: :left
  defp interpret_event(_other), do: nil

  defp print(mode, game) do
    Game.Formatter.format(mode, game)
    |> IO.write
    {:noreply, %{game: game}}
  end
end
