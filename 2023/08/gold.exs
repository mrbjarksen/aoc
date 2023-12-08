directions = IO.read(:line) |> String.trim() |> String.graphemes()

IO.read(:line)

{left, right} =
  IO.stream()
  |> Enum.map(fn line -> Regex.scan(~r/[A-Z0-9]{3}/, line) |> Enum.map(&hd/1) end)
  |> Enum.reduce({%{}, %{}}, fn [from, to_left, to_right], {left, right} ->
    {Map.put(left, from, to_left), Map.put(right, from, to_right)}
  end)

# A list of tuples `{start, length, ends}` describing the cycles reached
# from each starting node, where `start` is the starting index of the cycle,
# `length` is the length of the cycle, and `ends` is a list of indices of ending nodes within the cycle
# This solution assumes all paths have reached a cycle before the solution is found.
cycles =
  Map.keys(left)
  |> Enum.filter(&(String.last(&1) == "A"))
  |> Enum.map(fn start ->
    Stream.cycle(directions)
    |> Stream.scan(start, fn
        "L", node -> left[node]
        "R", node -> right[node]
    end)
    |> Stream.with_index(1)
    |> Enum.reduce_while({%{{start, 0} => 0}, 1}, fn {node, index}, {visit, dir} ->
      case Map.get(visit, {node, dir}) do
        nil -> {:cont, {Map.put(visit, {node, dir}, index), rem(dir + 1, length(directions))}}
        start -> 
          length = index - start
          ends =
            Map.filter(visit, fn {{n, _}, i} -> String.last(n) == "Z" && i >= start end)
            |> Map.values()
            |> Enum.map(&(&1 - start))
          {:halt, {start, length, ends}}
      end
    end)
  end)

Enum.each(cycles, &IO.inspect/1)

# Inspection shows that each of the cycles in the input has exactly one endend
# (actually, this could be deduced from the problem text, whoops!),
# each of which is reached after as many steps as the length of the cycles.
# This significantly simplifies the calculation, as the answer is then simply
# the lowest common multiple of the cycle lengths.
# (I'm too lazy to implement it in Elixir, so I used WolframAlpha)
