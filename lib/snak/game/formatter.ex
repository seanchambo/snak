defmodule Snak.Game.Formatter do
  alias IO.ANSI
  alias Snak.{Grid, Game, IO}

  @controls  "W: UP  S: Down  A: Left  D: Right  P: Pause  Space: Resume/Start"
  @paused    "PAUSED       "
  @game_over "GAME OVER    "

  def format(:start_screen, _),do: start_screen()
  def format(:started, game),  do: init_game(game)
  def format(:running, game),  do: update(game)
  def format(:paused, game),   do: paused(game)
  def format(:ended, game),    do: ended(game)

  defp start_screen do
    [ANSI.clear, ANSI.home,
      IO.move_cursor(Grid.height / 2 - 6, Grid.width - 10),
      ANSI.red,
      "####  #   #  ####  #  #",
      IO.move_cursor(Grid.height / 2 - 5, Grid.width - 10),
      ANSI.green,
      "#     ##  #  #  #  # #",
      IO.move_cursor(Grid.height / 2 - 4, Grid.width - 10),
      ANSI.light_yellow,
      "####  # # #  ####  ##",
      IO.move_cursor(Grid.height / 2 - 3, Grid.width - 10),
      ANSI.magenta,
      "   #  #  ##  #  #  # #",
      IO.move_cursor(Grid.height / 2 - 2, Grid.width - 10),
      ANSI.cyan,
      "####  #   #  #  #  #  #",
      IO.move_cursor(Grid.height / 2, Grid.width - 13),
      ANSI.white,
      "Created by Sean Chamberlain",
      IO.move_cursor(Grid.height / 2 + 2, Grid.width - 13),
      "--| PRESS SPACE TO START |--",
    ]
  end

  defp init_game(game), do: [ANSI.clear, ANSI.home, draw_grid(), draw_controls(), draw_game(game)]
  defp paused(game),    do: [draw_info(game)]
  defp ended(game),     do: [draw_info(game)]
  defp update(game),    do: [draw_game(game)]

  defp draw_game(game) do
    [
      draw_snake(:queue.to_list(game.grid.snake)),
      undraw_snake_tail(game.grid.old_tail),
      draw_apple(game.grid.apple),
      draw_mode(game)
    ]
  end

  defp draw_info(game), do: [draw_mode(game), draw_controls()]

  defp draw_mode(%Game{mode: :paused}),                do: draw_mode(@paused)
  defp draw_mode(%Game{mode: :ended}),                 do: draw_mode(@game_over)
  defp draw_mode(%Game{mode: :running, score: score}), do: draw_mode("SCORE: #{score}")
  defp draw_mode(string),                              do: [IO.move_cursor(25, 2), string]

  defp draw_controls,               do: [IO.move_cursor(25, 18), @controls]

  defp draw_grid,                   do: Grid.Formatter.draw_walls
  defp draw_snake(positions),       do: Grid.Formatter.draw_snake(positions)
  defp undraw_snake_tail(position), do: Grid.Formatter.undraw_snake_tail(position)
  defp draw_apple(position),        do: Grid.Formatter.draw_apple(position)
end
