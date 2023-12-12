defmodule Springs do
  def possibilities([]), do: [[]]

  def possibilities([:operational | springs]) do
    Enum.map(possibilities(springs), &[:operational | &1])
  end

  def possibilities([:damaged | springs]) do
    Enum.map(possibilities(springs), &[:damaged | &1])
  end

  def possibilities([:unknown | springs]) do
    possibilities([:operational | springs]) ++ possibilities([:damaged | springs])
  end

  def groups(springs) do
    Enum.chunk_while(
      springs,
      0,
      fn
        :damaged, n -> {:cont, n + 1}
        _, 0 -> {:cont, 0}
        _, n -> {:cont, n, 0}
      end,
      fn
        0 -> {:cont, 0}
        n -> {:cont, n, 0}
      end
    )
  end
end

IO.stream()
|> Stream.map(fn line ->
  [springs, groups] = String.split(line)

  springs =
    String.graphemes(springs)
    |> Enum.map(fn
      "." -> :operational
      "#" -> :damaged
      "?" -> :unknown
    end)

  groups = String.split(groups, ",") |> Enum.map(&String.to_integer/1)

  Enum.count(Springs.possibilities(springs), &(Springs.groups(&1) == groups))
end)
|> Enum.sum()
|> IO.puts()
