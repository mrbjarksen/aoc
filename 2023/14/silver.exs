IO.stream()
|> Enum.map(&String.to_charlist/1)
|> Enum.zip_with(&Function.identity/1)
|> Enum.map(fn col ->
  n = length(col)

  Enum.zip(col, n..1)
  |> Enum.reduce({0, n}, fn {rock, weight}, {total, next} ->
    case rock do
      ?O -> {total + next, next - 1}
      ?# -> {total, weight - 1}
      _ -> {total, next}
    end
  end)
  |> elem(0)
end)
|> Enum.sum()
|> IO.puts()
