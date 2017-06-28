defmodule Snak.Grid.Formatter do
  alias IO.ANSI
  alias Snak.{Grid, IO}

  def draw_walls() do
    Enum.map(1..Grid.height, fn row->
      Enum.map(1..Grid.width, fn col->
        draw_wall(row, col)
      end)
    end)
  end

  def draw_snake(snake_positions) do
    Enum.map(snake_positions, fn %{x: x, y: y}->
      draw_snake_cell(y, x)
    end)
  end

  def undraw_snake_tail(position), do: undraw_snake_tail_cell(position)

  def draw_apple(position), do: draw_apple_cell(position)

  defp draw_wall(1, col),   do: draw_wall_cell(1, col)
  defp draw_wall(24, col),  do: draw_wall_cell(24, col)
  defp draw_wall(row, 1),   do: draw_wall_cell(row, 1)
  defp draw_wall(row, 40),  do: draw_wall_cell(row, 40)
  defp draw_wall(_, _),     do: ''

  defp draw_snake_cell(row, col) do
    [IO.move_cursor(row, col * 2), ANSI.light_magenta_background, '  ', ANSI.black_background]
  end

  defp undraw_snake_tail_cell(%{x: col, y: row}) do
    [IO.move_cursor(row, col * 2), ANSI.black_background, '  ']
  end
  defp undraw_snake_tail_cell(_), do: []

  defp draw_wall_cell(row, col) do
    [IO.move_cursor(row, col * 2), ANSI.light_blue_background,'  ', ANSI.black_background]
  end

  defp draw_apple_cell(%{x: col, y: row}) do
    [IO.move_cursor(row, col * 2), ANSI.light_green_background, '  ', ANSI.black_background]
  end
end
