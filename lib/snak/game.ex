defmodule Snak.Game do
  defstruct [:grid, score: 0, mode: :init, direction: :up]

  use GenServer

  alias Snak.{Grid, IO}

  @start_tick 100

  def start_link,           do: GenServer.start_link(__MODULE__, [], name: Game)
  def init(_),              do: {:ok, %{game: new_game()}}
  def start,                do: GenServer.cast(Game, {:start})
  def pause,                do: GenServer.cast(Game, {:pause})
  def direction(direction), do: GenServer.cast(Game, {:change_direction, direction})

  def handle_cast({:start}, %{game: game}) do
    game = case game.mode do
      :ended -> new_game() |> set_mode(:running)
      _      -> game       |> set_mode(:running)
    end

    IO.print_mode(:started, game)
    tick(game)
  end

  def handle_cast({:pause}, %{game: game}) do
    game = changeset(game, %{mode: :paused})
    {:noreply, %{game: game}}
  end

  def handle_cast({:change_direction, direction}, %{game: game}) do
    case can_change_direction?(game, direction) do
      true  -> {:noreply, %{game: changeset(game, %{direction: direction})}}
      false -> {:noreply, %{game: game}}
    end
  end

  def handle_info(:tick, %{game: game}) do
    game
      |> move_snake
      |> changeset
      |> redraw_game
      |> tick
  end

  defp move_snake(game) do
    Grid.move_snake(game)
  end

  defp redraw_game(game = %__MODULE__{mode: mode}) do
    IO.print_mode(mode, game)
  end

  defp tick(game = %__MODULE__{score: score, mode: :running}) do
    Process.send_after(self(), :tick, round(@start_tick - score / 10))
    {:noreply, %{game: game}}
  end
  defp tick({_, %{game: game}}), do: tick(game)
  defp tick(game),               do: {:noreply, %{game: game}}

  defp new_game, do: changeset(%{grid: Grid.new()})

  defp changeset({game, changes, :ate_apple}), do: changeset(game, changes) |> increase_score
  defp changeset({game, changes, :collision}), do: changeset(game, changes) |> set_mode(:ended)
  defp changeset({game, changes, _}),          do: changeset(game, changes)
  defp changeset(changes),                     do: struct(%__MODULE__{}, changes)
  defp changeset(game, changes),               do: struct(game, changes)

  defp increase_score(game), do: changeset(game, %{score: game.score + 10})
  defp set_mode(game, mode), do: changeset(game, %{mode: mode})

  defp can_change_direction?(%__MODULE__{direction: :up}, :down),    do: false
  defp can_change_direction?(%__MODULE__{direction: :down}, :up),    do: false
  defp can_change_direction?(%__MODULE__{direction: :left}, :right), do: false
  defp can_change_direction?(%__MODULE__{direction: :right}, :left), do: false
  defp can_change_direction?(%__MODULE__{direction: dir}, dir),      do: false
  defp can_change_direction?(_, _),                                  do: true
end
