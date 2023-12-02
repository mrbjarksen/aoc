max_color = fn game, color ->
  Regex.compile!("(\\d+) #{color}")
  |> Regex.scan(game, capture: :all_but_first)
  |> Enum.map(&String.to_integer(hd(&1)))
  |> Enum.max(&>=/2, fn -> 0 end)
end

IO.stream()
|> Enum.map(fn game ->
  max_color.(game, "red") * max_color.(game, "green") * max_color.(game, "blue")
end)
|> Enum.sum()
|> IO.puts()
