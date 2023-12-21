input = IO.stream() |> Enum.map(&(String.trim(&1) |> String.to_charlist()))

num_rows = length(input)
num_cols = length(hd(input))

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

Enum.reduce(1..64, MapSet.new([start]), fn _, possibilities ->
  Enum.flat_map(possibilities, fn {i, j} ->
    [{i + 1, j}, {i - 1, j}, {i, j + 1}, {i, j - 1}]
    |> Enum.filter(fn {i, j} ->
      0 <= i && i < num_rows && 0 <= j && j < num_cols && !MapSet.member?(rocks, {i, j})
    end)
  end)
  |> Enum.into(MapSet.new())
end)
|> MapSet.size()
|> IO.puts()
