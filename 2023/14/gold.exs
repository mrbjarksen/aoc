defmodule Dish do
  def tilt(dish) do
    Enum.map(dish, fn line ->
      {rolled, dots} =
        Enum.reduce(line, {[], 0}, fn rock, {rolled, dots} ->
          case rock do
            ?O -> {[?O | rolled], dots}
            ?. -> {rolled, dots + 1}
            ?# -> {[?# | for(_ <- 1..dots//1, do: ?.)] ++ rolled, 0}
          end
        end)

      Enum.reverse(for(_ <- 1..dots//1, do: ?.) ++ rolled)
    end)
  end

  def rotate(dish, direction \\ :clockwise)

  def rotate(dish, :clockwise) do
    Enum.reverse(dish) |> Enum.zip_with(&Function.identity/1)
  end

  def rotate(dish, :counterclockwise) do
    Enum.zip_with(dish, &Function.identity/1) |> Enum.reverse()
  end

  def cycle(dish) do
    Enum.reduce(1..4, dish, fn _, dish ->
      Dish.tilt(dish) |> Dish.rotate()
    end)
  end

  def load(dish) do
    Enum.map(dish, fn line ->
      n = length(line)

      Enum.zip(line, n..1)
      |> Enum.filter(fn {rock, _} -> rock == ?O end)
      |> Enum.map(fn {_, weight} -> weight end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def inspect(dish) do
    Dish.rotate(dish) |> Enum.each(&IO.puts("#{&1}"))
    IO.puts("")
    dish
  end
end

dish =
  IO.stream()
  |> Enum.map(&(String.trim(&1) |> String.to_charlist()))
  |> Dish.rotate(:counterclockwise)

Enum.reduce_while(1..1_000_000_000, {dish, %{}}, fn i, {dish, seen} ->
  case Map.get(seen, dish) do
    nil ->
      {:cont, {Dish.cycle(dish), Map.put(seen, dish, i)}}

    j ->
      n = rem(1_000_000_000 - j, i - j)

      final =
        Enum.reduce(1..(n + 1)//1, dish, fn _, dish ->
          Dish.cycle(dish)
        end)

      {:halt, final}
  end
end)
|> Dish.load()
|> IO.puts()
