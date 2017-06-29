defmodule Snak.Grid do
  defstruct [:snake, apple: %{x: 0, y: 0}, old_tail: nil]

  alias Snak.Game

  @init_snake :queue.from_list([%{x: 20, y: 11}, %{x: 20, y: 12}, %{x: 20, y: 13}])

  def width, do: 40
  def height, do: 24

  def new, do: changeset(%__MODULE__{}, %{snake: @init_snake}) |> generate_apple

  def move_snake(game = %Game{direction: direction, grid: grid}) do
    {grid, status} = current_head(grid.snake)
      |> validate_move(grid, direction)
      |> perform_move

    {game, %{grid: grid}, status}
  end

  defp validate_move(head, grid, direction) do
    head
      |> move_head(direction)
      |> perform_collision_checks(grid)
  end

  defp perform_move({head, grid, status}) do
    grid = head
     |> add_head(grid.snake)
     |> remove_tail(status)
     |> (&changeset(grid, &1, status)).()

     {grid, status}
  end

  defp current_head(snake), do: :queue.get(snake)

  defp move_head(position, :up),    do: %{x: position.x, y: position.y - 1}
  defp move_head(position, :down),  do: %{x: position.x, y: position.y + 1}
  defp move_head(position, :left),  do: %{x: position.x - 1, y: position.y}
  defp move_head(position, :right), do: %{x: position.x + 1, y: position.y}

  defp add_head(head, snake), do: :queue.in_r(head, snake)

  defp perform_collision_checks(head, grid) do
    status = cond do
      head == grid.apple              -> :ate_apple
      head.x == 1 or head.x == 40     -> :collision
      head.y == 1 or head.y == 24     -> :collision
      :queue.member(head, grid.snake) -> :collision
      true                            -> :ok
    end

    {head, grid, status}
  end

  defp remove_tail(snake, :ok) do
    {{_, old_tail}, snake} = :queue.out_r(snake)
    %{snake: snake, old_tail: old_tail}
  end
  defp remove_tail(snake, _), do: %{snake: snake, old_tail: nil}

  defp changeset(grid, opts),             do: struct(grid, opts)
  defp changeset(grid, opts, :ate_apple), do: changeset(grid, opts) |> generate_apple
  defp changeset(grid, opts, _),          do: changeset(grid, opts)

  defp generate_apple(grid) do
    position = %{x: Enum.random(2..39), y: Enum.random(2..23)}

    case :queue.member(position, grid.snake) do
      true -> generate_apple(grid)
      false -> %{grid | apple: position}
    end
  end
end
