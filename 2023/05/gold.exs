seeds =
  IO.read(:line)
  |> String.replace_prefix("seeds: ", "")
  |> String.split()
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(2)

maps =
  IO.read(:all)
  |> String.split("\n\n")
  |> Enum.map(fn raw_map -> 
    listings = String.trim(raw_map) |> String.split("\n") |> tl
    Enum.map(listings, fn lst ->
      String.split(lst) |> Enum.map(&String.to_integer/1)
    end)
  end)

defmodule Iter do
  def first(from, fun) do
    if fun.(from) do
      from
    else
      first(from + 1, fun)
    end
  end
end

Iter.first(0, fn location ->
  seed = Enum.reduce(Enum.reverse(maps), location, fn map, num ->
    listing = Enum.find(map, fn [dst, _, len] ->
      dst <= num && num < dst + len
    end)
    case listing do
      nil -> num
      [dst, src, _] -> src + num - dst
    end
  end)
  Enum.find_value(seeds, fn [start, len] ->
    start <= seed && seed < start + len
  end)
end)
|> IO.puts()
