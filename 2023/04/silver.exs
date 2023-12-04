IO.stream()
|> Enum.map(fn card ->
  [_, card] = String.split(card, ": ", parts: 2)

  [winners, numbers] =
    String.split(card, " | ")
    |> Enum.map(&Regex.scan(~r/\d+/, &1))

  case Enum.filter(numbers, &(&1 in winners)) |> length do
    0 -> 0
    n -> Integer.pow(2, n - 1)
  end
end)
|> Enum.sum()
|> IO.puts()
