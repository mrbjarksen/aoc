defmodule Mirror do
  defp find(_, []), do: []
  defp find([], [first | rest]), do: find([first], rest)

  defp find(start, rest) do
    if List.starts_with?(start, rest) || List.starts_with?(rest, start) do
      [length(start) | find([hd(rest) | start], tl(rest))]
    else
      find([hd(rest) | start], tl(rest))
    end
  end

  def find_rows(grid) do
    find([], grid)
  end

  def find_cols(grid) do
    find([], Enum.zip_with(grid, &Function.identity/1))
  end

  def find_all(grid) do
    {Mirror.find_rows(grid), Mirror.find_cols(grid)}
  end

  def desmudged(grid) do
    for i <- Enum.with_index(grid, fn _, i -> i end),
        j <- Enum.with_index(Enum.at(grid, i), fn _, j -> j end) do
      List.update_at(grid, i, fn row ->
        List.update_at(row, j, fn
          ?# -> ?.
          ?. -> ?#
        end)
      end)
    end
  end
end

IO.read(:all)
|> String.split("\n\n")
|> Enum.map(fn raw_grid ->
  grid = String.split(raw_grid, "\n", trim: true) |> Enum.map(&String.to_charlist/1)
  {rows, cols} = Mirror.find_all(grid)

  Mirror.desmudged(grid)
  |> Enum.map(fn grid ->
    {new_rows, new_cols} = Mirror.find_all(grid)

    case {new_rows -- rows, new_cols -- cols} do
      {[], []} -> nil
      {[], [col | _]} -> col
      {[row | _], _} -> 100 * row
    end
  end)
  |> Enum.find(&(&1 != nil))
end)
|> Enum.sum()
|> IO.puts()
