t = IO.read(:line) |> String.replace_prefix("Time:", "") |> String.replace(~r/\s+/, "") |> String.to_integer()
d = IO.read(:line) |> String.replace_prefix("Distance:", "") |> String.replace(~r/\s+/, "") |> String.to_integer()

Enum.filter(0..t, &(&1 * (t - &1) > d))
|> length()
|> IO.puts()
