directions = IO.read(:line) |> String.trim() |> String.graphemes()

IO.read(:line)

{left, right} =
  IO.stream()
  |> Enum.map(fn line -> Regex.scan(~r/[A-Z]{3}/, line) |> Enum.map(&hd/1) end)
  |> Enum.reduce({%{}, %{}}, fn [from, to_left, to_right], {left, right} ->
    {Map.put(left, from, to_left), Map.put(right, from, to_right)}
  end)

Stream.cycle(directions)
|> Stream.scan("AAA", fn dir, node ->
  case dir do
    "L" -> left[node]
    "R" -> right[node]
  end
end)
|> Enum.find_index(&(&1 == "ZZZ"))
|> (&(&1 + 1)).()
|> IO.puts()
