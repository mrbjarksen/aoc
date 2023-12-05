seeds =
  IO.read(:line)
  |> String.replace_prefix("seeds: ", "")
  |> String.split()
  |> Enum.map(&String.to_integer/1)

maps =
  IO.read(:all)
  |> String.split("\n\n")
  |> Enum.map(fn raw_map -> 
    listings = String.trim(raw_map) |> String.split("\n") |> tl
    Enum.map(listings, fn lst ->
      String.split(lst) |> Enum.map(&String.to_integer/1)
    end)
  end)

Enum.map(seeds, fn seed ->
  Enum.reduce(maps, seed, fn map, num ->
    listing = Enum.find(map, fn [_, src, len] ->
      src <= num && num < src + len
    end)
    case listing do
      nil -> num
      [dst, src, _] -> dst + num - src
    end
  end)
end)
|> Enum.min()
|> IO.puts()
