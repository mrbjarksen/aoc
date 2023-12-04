IO.stream()
|> Enum.reduce(%{}, fn line, instances ->
  [card, nums] = String.split(line, ": ", parts: 2)
  card = String.replace_prefix(card, "Card", "") |> String.trim_leading() |> String.to_integer()
  instances = Map.update(instances, card, 1, &(&1 + 1))

  [winners, numbers] =
    String.split(nums, " | ")
    |> Enum.map(&Regex.scan(~r/\d+/, &1))

  num_wins = Enum.filter(numbers, &(&1 in winners)) |> length
  num_cards = instances[card]

  for k <- 1..num_wins//1, reduce: instances do
    instances -> Map.update(instances, card + k, num_cards, &(&1 + num_cards))
  end
end)
|> Map.values()
|> Enum.sum()
|> IO.puts()
