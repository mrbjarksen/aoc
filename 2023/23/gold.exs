input =
  IO.stream()
  |> Enum.map(fn line ->
    String.trim(line)
    |> String.to_charlist()
    |> Enum.map(fn
      ?# -> ?#
      _ -> ?.
    end)
  end)

n = length(input)
m = length(hd(input))

defmodule Maze do
  defp walk(maze, {i, j, dir}, count \\ 0) do
    check =
      case dir do
        :right -> [:up, :down, :right]
        :left -> [:up, :down, :left]
        :up -> [:up, :left, :right]
        :down -> [:down, :left, :right]
      end

    steps =
      Enum.map(check, fn
        :up -> {i - 1, j, :up}
        :down -> {i + 1, j, :down}
        :right -> {i, j + 1, :right}
        :left -> {i, j - 1, :left}
      end)
      |> Enum.filter(fn {i, j, _} ->
        Map.get(maze, {i, j}) == ?.
      end)

    case steps do
      [step] -> walk(maze, step, count + 1)
      _ -> {i, j, count + 1}
    end
  end

  defp connections(maze, {i, j}) do
    [{i - 1, j, :up}, {i + 1, j, :down}, {i, j - 1, :left}, {i, j + 1, :right}]
    |> Enum.filter(fn {i, j, _} -> Map.get(maze, {i, j}) == ?. end)
    |> Enum.map(&walk(maze, &1))
  end

  def graph(maze, vs \\ [{0, 1}], found \\ %{})

  def graph(_, [], found), do: found

  def graph(maze, [v | vs], found) do
    connections = connections(maze, v)

    next =
      Enum.map(connections, fn {i, j, _} -> {i, j} end)
      |> Enum.reject(&Map.has_key?(found, &1))

    graph(maze, next ++ vs, Map.put(found, v, connections))
  end

  def longest_path(graph, from, to, dist \\ 0, visited \\ MapSet.new()) do
    next =
      Map.get(graph, from)
      |> Enum.reject(fn {i, j, _} -> MapSet.member?(visited, {i, j}) end)
      |> Enum.map(fn {i, j, w} ->
        longest_path(graph, {i, j}, to, dist + w, MapSet.put(visited, from))
      end)
      |> Enum.reject(&(&1 == nil))

    cond do
      from == to -> dist
      Enum.empty?(next) -> nil
      true -> Enum.max(next)
    end
  end
end

Stream.with_index(input)
|> Enum.reduce(%{}, fn {row, i}, map ->
  Enum.with_index(row)
  |> Enum.reduce(map, fn {c, j}, map -> Map.put(map, {i, j}, c) end)
end)
|> Maze.graph()
|> Maze.longest_path({0, 1}, {n - 1, m - 2})
|> IO.inspect()
