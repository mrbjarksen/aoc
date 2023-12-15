IO.read(:line)
|> String.trim_trailing()
|> String.split(",")
|> Enum.reduce(%{}, fn instruction, boxes ->
  case Regex.split(~r/=|-/, instruction) do
    [label, ""] ->
      box = String.to_charlist(label) |> Enum.reduce(0, &rem((&1 + &2) * 17, 256))
      Map.update(boxes, box, [], &List.keydelete(&1, label, 0))

    [label, focal] ->
      box = String.to_charlist(label) |> Enum.reduce(0, &rem((&1 + &2) * 17, 256))
      focal = String.to_integer(focal)
      Map.update(boxes, box, [{label, focal}], &List.keystore(&1, label, 0, {label, focal}))
  end
end)
|> Enum.map(fn {box, lenses} ->
  Enum.with_index(lenses, 1)
  |> Enum.map(fn {{_, focal}, i} ->
    (box + 1) * i * focal
  end)
  |> Enum.sum()
end)
|> Enum.sum()
|> IO.puts()
