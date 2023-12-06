times = IO.read(:line) |> String.trim() |> String.split(~r/\s+/) |> tl |> Enum.map(&String.to_integer/1)
dists = IO.read(:line) |> String.trim() |> String.split(~r/\s+/) |> tl |> Enum.map(&String.to_integer/1)

Enum.zip(times, dists)
|> Enum.map(fn {t, d} ->
  Enum.filter(0..t, &(&1 * (t - &1) > d)) |> length()
end)
|> Enum.product()
|> IO.puts()
