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

defmodule Disintigrate do
  def will_fall?(supports, disintigrated, block, cached \\ %{}) do
    if Map.has_key?(cached, {disintigrated, block}) do
      {Map.get(cached, {disintigrated, block}), cached}
    else
      case Map.get(supports, block, MapSet.new()) |> MapSet.to_list() do
        [] ->
          {false, Map.put(cached, {disintigrated, block}, false)}

        [^disintigrated] ->
          {true, Map.put(cached, {disintigrated, block}, true)}

        blocks ->
          {will_supports_fall, cached} =
            Enum.map_reduce(blocks, cached, fn i, cached ->
              if i == disintigrated do
                {true, cached}
              else
                {will_fall, cached} = will_fall?(supports, disintigrated, i, cached)
                {will_fall, Map.put(cached, {disintigrated, i}, will_fall)}
              end
            end)

          will_fall = Enum.all?(will_supports_fall)

          {will_fall, Map.put(cached, {disintigrated, block}, will_fall)}
      end
    end
  end

  def fall_count(supports, num_blocks, disintigrated, cached \\ %{}) do
    Enum.reduce(0..(num_blocks - 1), {0, cached}, fn i, {count, cached} ->
      {will_fall, cached} = will_fall?(supports, disintigrated, i, cached)

      if will_fall do
        {count + 1, cached}
      else
        {count, cached}
      end
    end)
  end
end

num_blocks = length(snapshot)

Enum.map_reduce(0..(num_blocks - 1), %{}, fn i, cached ->
  Disintigrate.fall_count(supports, num_blocks, i, cached)
end)
|> elem(0)
|> Enum.sum()
|> IO.puts()
