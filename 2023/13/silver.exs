defmodule Mirror do
  def find(start \\ [], rest)
  def find(_, []), do: nil
  def find([], [first | rest]), do: find([first], rest)

  def find(start, rest) do
    if List.starts_with?(start, rest) || List.starts_with?(rest, start) do
      length(start)
    else
      find([hd(rest) | start], tl(rest))
    end
  end
end

IO.read(:all)
|> String.split("\n\n")
|> Enum.map(fn raw_grid ->
  grid = String.split(raw_grid, "\n", trim: true) |> Enum.map(&String.to_charlist/1)

  case Mirror.find(grid) do
    nil -> Enum.zip_with(grid, &Function.identity/1) |> Mirror.find()
    i -> 100 * i
  end
end)
|> Enum.sum()
|> IO.puts()
