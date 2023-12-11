img = IO.stream() |> Enum.map(&(String.trim(&1) |> String.graphemes()))

empty_rows =
  Enum.with_index(img)
  |> Enum.filter(fn {line, _} -> Enum.all?(line, &(&1 == ".")) end)
  |> Enum.map(&elem(&1, 1))

empty_cols =
  Enum.zip_with(img, &Function.identity/1)
  |> Enum.with_index()
  |> Enum.filter(fn {line, _} -> Enum.all?(line, &(&1 == ".")) end)
  |> Enum.map(&elem(&1, 1))

defmodule Dist do
  def dist([], _, _, _), do: 0

  def dist([{i, j} | coords], expansion, empty_rows, empty_cols) do
    d =
      Enum.map(coords, fn {ci, cj} ->
        num_empty_rows = Enum.filter(empty_rows, &(min(i, ci) < &1 && &1 < max(i, ci))) |> length
        num_empty_cols = Enum.filter(empty_cols, &(min(j, cj) < &1 && &1 < max(j, cj))) |> length
        abs(ci - i) + abs(cj - j) + (num_empty_rows + num_empty_cols) * (expansion - 1)
      end)
      |> Enum.sum()

    d + dist(coords, expansion, empty_rows, empty_cols)
  end
end

Enum.map(img, fn line ->
  Enum.with_index(line)
  |> Enum.filter(fn {x, _} -> x == "#" end)
  |> Enum.map(&elem(&1, 1))
end)
|> Enum.with_index()
|> Enum.flat_map(fn {js, i} ->
  Enum.map(js, fn j -> {i, j} end)
end)
|> Dist.dist(1_000_000, empty_rows, empty_cols)
|> IO.puts()
