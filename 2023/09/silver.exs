defmodule Seq do
  def next(seq) do
    if Enum.all?(seq, &(&1 == 0)) do
      0
    else
      List.last(seq) + next(diff(seq))
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
  |> Seq.next()
end)
|> Enum.sum()
|> IO.puts()
