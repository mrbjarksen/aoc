# WARNING: this is ugly

field = IO.stream() |> Enum.map(&(String.trim(&1) |> String.graphemes()))

{si, sj} =
  Enum.map(field, &Enum.find_index(&1, fn p -> p == "S" end))
  |> Enum.with_index(fn p, i -> {i, p} end)
  |> Enum.find(fn {_, j} -> j != nil end)

sdir =
  cond do
    (Enum.at(field, si, []) |> Enum.at(sj + 1)) in ["-", "J", "7"] -> :right
    (Enum.at(field, si + 1, []) |> Enum.at(sj)) in ["|", "L", "J"] -> :down
    (Enum.at(field, si, []) |> Enum.at(sj - 1)) in ["-", "F", "L"] -> :left
    (Enum.at(field, si - 1, []) |> Enum.at(sj)) in ["|", "7", "F"] -> :up
    true -> nil
  end

other_sdir =
  cond do
    (Enum.at(field, si - 1, []) |> Enum.at(sj)) in ["|", "7", "F"] -> :up
    (Enum.at(field, si, []) |> Enum.at(sj - 1)) in ["-", "F", "L"] -> :left
    (Enum.at(field, si + 1, []) |> Enum.at(sj)) in ["|", "L", "J"] -> :down
    (Enum.at(field, si, []) |> Enum.at(sj + 1)) in ["-", "J", "7"] -> :right
    true -> nil
  end

step = fn {i, j, dir} ->
  case {dir, Enum.at(field, i) |> Enum.at(j)} do
    {:right, "-"} -> {i, j + 1, :right}
    {:right, "J"} -> {i - 1, j, :up}
    {:right, "7"} -> {i + 1, j, :down}
    {:down, "|"} -> {i + 1, j, :down}
    {:down, "L"} -> {i, j + 1, :right}
    {:down, "J"} -> {i, j - 1, :left}
    {:left, "-"} -> {i, j - 1, :left}
    {:left, "F"} -> {i + 1, j, :down}
    {:left, "L"} -> {i - 1, j, :up}
    {:up, "|"} -> {i - 1, j, :up}
    {:up, "7"} -> {i, j - 1, :left}
    {:up, "F"} -> {i, j + 1, :right}
  end
end

{ssi, ssj} =
  case sdir do
    :right -> {si, sj + 1}
    :down -> {si + 1, sj}
    :left -> {si, sj - 1}
    :up -> {si - 1, sj}
  end

set_true = fn grid, i, j ->
  List.update_at(grid, i, fn line -> List.update_at(line, j, fn _ -> true end) end)
end

Stream.iterate({ssi, ssj, sdir}, step)
|> Stream.take_while(fn {i, j, _} -> {i, j} != {si, sj} end)
|> Enum.reduce(
  Enum.map(field, &Enum.map(&1, fn _ -> false end)) |> set_true.(si, sj),
  fn {i, j, _}, grid -> set_true.(grid, i, j) end
)
|> Enum.zip_with(field, fn line_on_loop, line ->
  Enum.zip_with(line_on_loop, line, fn
    true, pipe -> pipe
    false, _ -> "."
  end)
end)
|> List.update_at(si, fn line ->
  List.update_at(line, sj, fn _ ->
    case {sdir, other_sdir} do
      {:up, :down} -> "|"
      {:down, :up} -> "|"
      {:left, :right} -> "-"
      {:right, :left} -> "-"
      {:up, :right} -> "L"
      {:right, :up} -> "L"
      {:left, :up} -> "J"
      {:up, :left} -> "J"
      {:left, :down} -> "7"
      {:down, :left} -> "7"
      {:down, :right} -> "F"
      {:right, :down} -> "F"
    end
  end)
end)
|> Enum.map(fn line ->
  Enum.reduce(line, {0, nil, false}, fn pipe, {k, dir, inside} ->
    case {pipe, dir} do
      {".", _} -> if inside, do: {k + 1, nil, true}, else: {k, nil, false}
      {"|", _} -> {k, nil, !inside}
      {"F", nil} -> {k, :up, inside}
      {"L", nil} -> {k, :down, inside}
      {"J", :up} -> {k, nil, !inside}
      {"J", :down} -> {k, nil, inside}
      {"7", :down} -> {k, nil, !inside}
      {"7", :up} -> {k, nil, inside}
      {"-", _} -> {k, dir, inside}
    end
  end)
  |> elem(0)
end)
|> Enum.sum()
|> IO.puts()
