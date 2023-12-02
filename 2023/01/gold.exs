parse_digit = fn digit ->
  case digit do
    "one" -> 1
    "two" -> 2
    "three" -> 3
    "four" -> 4
    "five" -> 5
    "six" -> 6
    "seven" -> 7
    "eight" -> 8
    "nine" -> 9
    _ -> Integer.parse(digit) |> elem(0)
  end
end

get_number = fn line ->
  numbers =
    ~r/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/
    |> Regex.scan(line, capture: :all_but_first)
    |> Enum.map(&hd/1)

  first = List.first(numbers) |> parse_digit.()
  last = List.last(numbers) |> parse_digit.()

  10 * first + last
end

IO.stream()
|> Enum.map(get_number)
|> Enum.sum()
|> IO.puts()
