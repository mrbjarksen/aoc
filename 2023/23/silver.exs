input =
  IO.stream()
  |> Enum.map(&(String.trim(&1) |> String.to_charlist()))

n = length(input)
m = length(hd(input))

maze =
  Stream.with_index(input)
  |> Enum.reduce(%{}, fn {row, i}, map ->
    Enum.with_index(row)
    |> Enum.reduce(map, fn {c, j}, map -> Map.put(map, {i, j}, c) end)
  end)

defmodule Maze do
  def walk(_, [], longest, _), do: longest

  def walk(maze, [{i, j, dir, num} | steps], longest, stop) do
    if {i, j} == stop do
      walk(maze, steps, max(longest, num), stop)
    else
      check =
        case dir do
          :right -> [:up, :down, :right]
          :left -> [:up, :down, :left]
          :up -> [:up, :left, :right]
          :down -> [:down, :left, :right]
        end

      new_steps =
        Enum.map(check, fn
          :up -> {i - 1, j, :up, num + 1}
          :down -> {i + 1, j, :down, num + 1}
          :right -> {i, j + 1, :right, num + 1}
          :left -> {i, j - 1, :left, num + 1}
        end)
        |> Enum.filter(fn
          {i, j, :up, _} -> Map.get(maze, {i, j}) in [?., ?^]
          {i, j, :down, _} -> Map.get(maze, {i, j}) in [?., ?v]
          {i, j, :left, _} -> Map.get(maze, {i, j}) in [?., ?<]
          {i, j, :right, _} -> Map.get(maze, {i, j}) in [?., ?>]
        end)

      walk(maze, new_steps ++ steps, longest, stop)
    end
  end
end

Maze.walk(maze, [{0, 1, :down, 0}], 0, {n - 1, m - 2})
|> IO.puts()
