snapshot =
  IO.stream()
  |> Enum.map(fn line ->
    [x1, y1, z1, x2, y2, z2] =
      Regex.run(~r/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    if z2 < z1 do
      {{x2, y2, z2}, {x1, y1, z1}}
    else
      {{x1, y1, z1}, {x2, y2, z2}}
    end
  end)
  |> Enum.sort(fn {{_, _, za}, _}, {{_, _, zb}, _} -> za <= zb end)

{_, fallen} =
  Enum.reduce(snapshot, {%{}, []}, fn {{x1, y1, z1}, {x2, y2, z2}}, {height, fallen} ->
    covers =
      cond do
        x1 != x2 -> Enum.map(x1..x2, fn x -> {x, y1} end)
        y1 != y2 -> Enum.map(y1..y2, fn y -> {x1, y} end)
        true -> [{x1, y1}]
      end

    new_height = 1 + z2 - z1 + (Enum.map(covers, &Map.get(height, &1, 0)) |> Enum.max())

    height = Enum.reduce(covers, height, &Map.put(&2, &1, new_height))

    {height, [{{x1, y1, new_height - (z2 - z1)}, {x2, y2, new_height}} | fallen]}
  end)

fallen = Enum.reverse(fallen)

blocks =
  Enum.with_index(fallen)
  |> Enum.reduce(%{}, fn {{{x1, y1, z1}, {x2, y2, z2}}, i}, blocks ->
    coords =
      cond do
        x1 != x2 -> Enum.map(x1..x2, fn x -> {x, y1, z1} end)
        y1 != y2 -> Enum.map(y1..y2, fn y -> {x1, y, z1} end)
        true -> Enum.map(z1..z2, fn z -> {x1, y1, z} end)
      end

    Enum.reduce(coords, blocks, fn c, blocks -> Map.put(blocks, c, i) end)
  end)

supports =
  Enum.reduce(blocks, %{}, fn {{x, y, z}, i}, supports ->
    j = Map.get(blocks, {x, y, z - 1})

    if i != j && j != nil do
      Map.update(supports, i, MapSet.new([j]), &MapSet.put(&1, j))
    else
      supports
    end
  end)

disintigratable =
  Enum.map(0..(length(snapshot) - 1), &{&1, true})
  |> Map.new()

Enum.reduce(supports, disintigratable, fn {_, supported_by}, disintigratable ->
  if MapSet.size(supported_by) == 1 do
    [i] = MapSet.to_list(supported_by)
    Map.put(disintigratable, i, false)
  else
    disintigratable
  end
end)
|> Enum.count(fn {_, d} -> d end)
|> IO.puts()
