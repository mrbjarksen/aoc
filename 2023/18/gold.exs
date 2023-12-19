IO.stream()
|> Enum.map(fn line ->
  # [dir, steps, _] = String.split(line)
  # {String.to_atom(dir), String.to_integer(steps)}

  [_, _, hex] = String.split(line)

  hex = String.replace_prefix(hex, "(#", "") |> String.replace_suffix(")", "")

  dir =
    case String.last(hex) do
      "0" -> :R
      "1" -> :D
      "2" -> :L
      "3" -> :U
    end

  steps = String.slice(hex, 0..4) |> String.to_integer(16)

  {dir, steps}
end)
|> Enum.reduce({0, 0, %{}}, fn {dir, steps}, {i, j, corners} ->
  corners = Map.update(corners, i, MapSet.new([j]), &MapSet.put(&1, j))

  {i, j} =
    case dir do
      :U -> {i - steps, j}
      :D -> {i + steps, j}
      :L -> {i, j - steps}
      :R -> {i, j + steps}
    end

  {i, j, corners}
end)
|> elem(2)
|> Enum.sort_by(&elem(&1, 0))
|> Enum.reduce(nil, fn
  {i, corners}, nil ->
    # per_line =
    #   Enum.sort(corners)
    #   |> Enum.chunk_every(2)
    #   |> Enum.map(fn [j1, j2] -> j2 - j1 + 1 end)
    #   |> Enum.sum()
    # IO.puts("#{i}: #{per_line}")
    {0, i, corners}

  {i, corners}, {count, last_i, above} ->
    below = MapSet.difference(MapSet.union(corners, above), MapSet.intersection(corners, above))

    overlap =
      MapSet.union(above, below)
      |> Enum.sort()
      |> Enum.reduce({0, nil, nil}, fn j, {n, last_up, last_down} ->
        n = if last_up != nil && last_down != nil do
          n + j - max(last_up, last_down) + 1
        else
          n
        end

        last_up = if MapSet.member?(above, j) do
          if last_up == nil, do: j, else: nil
        else
          last_up
        end

        last_down = if MapSet.member?(below, j) do
          if last_down == nil, do: j, else: nil
        else
          last_down
        end

        {n, last_up, last_down}
      end)
      |> elem(0)

    per_line =
      Enum.sort(above)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [j1, j2] -> j2 - j1 + 1 end)
      |> Enum.sum()

    # Enum.each(last_i+1..i-1//1, fn ii -> IO.puts("#{ii}: #{per_line}") end)

    # per_line_below =
    #   Enum.sort(below)
    #   |> Enum.chunk_every(2)
    #   |> Enum.map(fn [j1, j2] -> j2 - j1 + 1 end)
    #   |> Enum.sum()

    # IO.puts("#{i}: #{per_line_below + per_line - overlap}")

    # IO.inspect({Enum.sort(above), Enum.sort(below), per_line, overlap})

    {count + per_line * (i - last_i + 1) - overlap, i, below}
end)
|> elem(0)
|> IO.puts()
