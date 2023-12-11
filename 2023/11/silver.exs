defmodule Dist do
  def dist([]), do: 0

  def dist([{i, j} | coords]) do
    d = Enum.map(coords, fn {ci, cj} -> abs(ci - i) + abs(cj - j) end) |> Enum.sum()
    d + dist(coords)
  end
end

IO.stream()
|> Enum.map(&(String.trim(&1) |> String.graphemes()))
|> Enum.flat_map(fn line ->
  if Enum.all?(line, &(&1 == ".")), do: [line, line], else: [line]
end)
|> Enum.zip_with(&Function.identity/1)
|> Enum.flat_map(fn line ->
  if Enum.all?(line, &(&1 == ".")), do: [line, line], else: [line]
end)
|> Enum.zip_with(&Function.identity/1)
|> Enum.map(fn line ->
  Enum.with_index(line)
  |> Enum.filter(fn {x, _} -> x == "#" end)
  |> Enum.map(&elem(&1, 1))
end)
|> Enum.with_index()
|> Enum.flat_map(fn {js, i} ->
  Enum.map(js, fn j -> {i, j} end)
end)
|> Dist.dist()
|> IO.puts()
