field = IO.stream() |> Enum.map(&String.graphemes/1)

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

Stream.iterate({ssi, ssj, sdir}, step)
|> Stream.take_while(fn {i, j, _} -> {i, j} != {si, sj} end)
|> Enum.to_list()
|> length()
|> (&(&1 + 1)).()
|> div(2)
|> IO.puts()
