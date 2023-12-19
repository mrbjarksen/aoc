trench =
  IO.stream()
  |> Enum.map(fn line ->
    [dir, steps, _] = String.split(line)
    {String.to_atom(dir), String.to_integer(steps)}
  end)
  |> Enum.reduce({0, 0, %{}}, fn {dir, steps}, acc ->
    Enum.reduce(1..steps, acc, fn _, {i, j, trench} ->
      case dir do
        :U -> {i - 1, j, Map.put(trench, {i, j}, dir)}
        :D -> {i + 1, j, Map.put(trench, {i, j}, dir)}
        :L -> {i, j - 1, Map.put(trench, {i, j}, dir)}
        :R -> {i, j + 1, Map.put(trench, {i, j}, dir)}
      end
    end)
  end)
  |> elem(2)

{min_i, max_i} = Map.keys(trench) |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
{min_j, max_j} = Map.keys(trench) |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

Enum.map(min_i..max_i, fn i ->
  IO.write("#{i}: ")
  Enum.reduce(min_j..max_j, {0, nil, false}, fn j, {k, last_dir, inside} ->
    check_dir =
      cond do
        Map.get(trench, {i, j}) in [:U, :D] -> Map.get(trench, {i, j})
        Map.get(trench, {i - 1, j}) == :D -> :D
        Map.get(trench, {i + 1, j}) == :U -> :U
        true -> Map.get(trench, {i, j})
      end

    case {check_dir, last_dir} do
      {nil, nil} when inside -> {k + 1, nil, true}
      {nil, nil} -> {k, nil, false}
      {dir, nil} -> {k + 1, dir, inside}
      {nil, _} when inside -> {k, nil, false}
      {nil, _} -> {k + 1, nil, true}
      {:U, :U} -> {k + 1, nil, !inside}
      {:D, :D} -> {k + 1, nil, !inside}
      {:U, :D} -> {k + 1, nil, inside}
      {:D, :U} -> {k + 1, nil, inside}
      _ -> {k + 1, last_dir, inside}
    end
  end)
  |> elem(0)
  |> IO.inspect()
end)
|> Enum.sum()
|> IO.puts()
