defmodule Snak.Grid do
  defstruct [:snake, apple: %{x: 0, y: 0}, old_tail: nil]

  alias Snak.Game

  @init_snake :queue.from_list([%{x: 20, y: 11}, %{x: 20, y: 12}, %{x: 20, y: 13}])

  def width, do: 40
  def height, do: 24

  def new, do: changeset(%__MODULE__{}, %{snake: @init_snake}) |> generate_apple

  def move_snake(game = %Game{direction: direction, grid: grid}) do
    with {:ok, head}    <- current_head(grid.snake),
         {:ok, head}    <- move_head(head, direction),
         {status}       <- perform_collision_checks(head, grid),
         {:ok, snake}   <- add_head_to_snake(head, grid.snake),
         {:ok, changes} <- remove_tail_from_snake(status, snake),
         do: {game, %{grid: changeset(grid, changes, status)}, status}
  end

  defp current_head(snake), do: {:ok, :queue.get(snake)}

  defp move_head(position, :up),    do: {:ok, %{x: position.x, y: position.y - 1}}
  defp move_head(position, :down),  do: {:ok, %{x: position.x, y: position.y + 1}}
  defp move_head(position, :left),  do: {:ok, %{x: position.x - 1, y: position.y}}
  defp move_head(position, :right), do: {:ok, %{x: position.x + 1, y: position.y}}

  defp add_head_to_snake(head, snake), do: {:ok, :queue.in_r(head, snake)}

  defp perform_collision_checks(head, grid) do
    cond do
      head == grid.apple              -> {:ate_apple}
      head.x == 1 or head.x == 40     -> {:collision}
      head.y == 1 or head.y == 24     -> {:collision}
      :queue.member(head, grid.snake) -> {:collision}
      true                            -> {:ok}
    end
  end

  defp remove_tail_from_snake(:ok, snake) do
    {{_, old_tail}, snake} = :queue.out_r(snake)
    {:ok, %{snake: snake, old_tail: old_tail}}
  end
  defp remove_tail_from_snake(_, snake), do: {:ok, %{snake: snake, old_tail: nil}}

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
