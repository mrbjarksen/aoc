IO.read(:line)
|> String.trim_trailing()
|> String.split(",")
|> Enum.map(fn string ->
  String.to_charlist(string)
  |> Enum.reduce(0, &rem((&1 + &2) * 17, 256))
end)
|> Enum.sum()
|> IO.puts()
