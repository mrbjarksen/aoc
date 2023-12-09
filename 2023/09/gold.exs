defmodule Seq do
  def prev(seq) do
    if Enum.all?(seq, &(&1 == 0)) do
      0
    else
      List.first(seq) - prev(diff(seq))
    end
  end

  def diff(seq) do
    Enum.zip_with(seq, tl(seq), &(&2 - &1))
  end
end

IO.stream()
|> Enum.map(fn line ->
  String.split(line)
  |> Enum.map(&String.to_integer/1)
  |> Seq.prev()
end)
|> Enum.sum()
|> IO.puts()
