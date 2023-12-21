input = IO.stream() |> Enum.map(&(String.trim(&1) |> String.to_charlist()))

n = length(input)

{rocks, start} =
  Enum.with_index(input)
  |> Enum.reduce({MapSet.new(), nil}, fn {row, i}, acc ->
    Enum.with_index(row)
    |> Enum.reduce(acc, fn
      {?#, j}, {rocks, start} -> {MapSet.put(rocks, {i, j}), start}
      {?S, j}, {rocks, nil} -> {rocks, {i, j}}
      {_, _}, {rocks, start} -> {rocks, start}
    end)
  end)

steps = 26_501_365

defmodule Step do
  def fill(rocks, n, current, previous \\ MapSet.new(), step \\ 0) do
    next = step(rocks, n, current)

    if MapSet.equal?(next, previous) do
      {step - 1, MapSet.size(previous), MapSet.size(current)}
    else
      fill(rocks, n, next, current, step + 1)
    end
  end

  def step(rocks, n, possibilities) do
    Enum.flat_map(possibilities, fn {i, j} ->
      [{i + 1, j}, {i - 1, j}, {i, j + 1}, {i, j - 1}]
      |> Enum.filter(fn {i, j} ->
        0 <= i && i < n && 0 <= j && j < n && !MapSet.member?(rocks, {i, j})
      end)
    end)
    |> Enum.into(MapSet.new())
  end

  def count(rocks, n, start, num_steps) do
    Enum.reduce(1..num_steps, MapSet.new([start]), fn _, possibilities ->
      step(rocks, n, possibilities)
    end)
    |> MapSet.size()
  end
end

{first_step, first_size, second_size} = Step.fill(rocks, n, MapSet.new([start]))

{size_of_filled_odd, size_of_filled_even} =
  if rem(first_step, 2) == 1 do
    {first_size, second_size}
  else
    {second_size, first_size}
  end

{r, s} = {div(steps, n), rem(steps, n)}

corners_small =
  [{0, 0}, {0, n - 1}, {n - 1, 0}, {n - 1, n - 1}]
  |> Enum.map(&Step.count(rocks, n, &1, s - 1))
  |> Enum.sum()

corners_big =
  [{0, 0}, {0, n - 1}, {n - 1, 0}, {n - 1, n - 1}]
  |> Enum.map(&Step.count(rocks, n, &1, s + n - 1))
  |> Enum.sum()

{si, sj} = start

edges =
  [{0, sj}, {n - 1, sj}, {si, 0}, {si, n - 1}]
  |> Enum.map(&Step.count(rocks, n, &1, s + si))
  |> Enum.sum()

m = div(r, 2)

{num_filled_odd, num_filled_even} =
  if rem(r, 2) == 1 do
    {4 * m * m, 1 + 4 * m * (m + 1)}
  else
    {1 + 4 * m * (m - 1), 4 * m * m}
  end

IO.puts(
  num_filled_odd * size_of_filled_odd +
    num_filled_even * size_of_filled_even +
    r * corners_small +
    (r - 1) * corners_big +
    edges
)
