get_number = fn line ->
  case String.split(line, ~r/[^0-9]*/, trim: true) do
    [] ->
      0

    digits ->
      {first, _} = List.first(digits) |> Integer.parse()
      {last, _} = List.last(digits) |> Integer.parse()
      10 * first + last
  end
end

IO.stream()
|> Enum.map(get_number)
|> Enum.sum()
|> IO.puts()
