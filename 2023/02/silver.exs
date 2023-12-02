max_color = fn game, color ->
  Regex.compile!("(\\d+) #{color}")
  |> Regex.scan(game, capture: :all_but_first)
  |> Enum.map(&String.to_integer(hd(&1)))
  |> Enum.max(&>=/2, fn -> 0 end)
end

IO.stream()
|> Enum.filter(&(max_color.(&1, "red") <= 12))
|> Enum.filter(&(max_color.(&1, "green") <= 13))
|> Enum.filter(&(max_color.(&1, "blue") <= 14))
|> Enum.map(fn game -> Regex.run(~r/\d+/, game) |> hd |> String.to_integer() end)
|> Enum.sum()
|> IO.puts()
