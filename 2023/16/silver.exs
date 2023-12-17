defmodule Beam do
  defp fire(_, [], found, _, _), do: found

  defp fire(contraption, [{i, j, dir} | beams], found, num_rows, num_cols) do
    if i < 0 || i >= num_rows || j < 0 || j >= num_cols || MapSet.member?(found, {i, j, dir}) do
      fire(contraption, beams, found, num_rows, num_cols)
    else
      found = MapSet.put(found, {i, j, dir})
      case {dir, Map.get(contraption, {i, j})} do
        {:right, ?/ } -> fire(contraption, [{i - 1, j, :up} | beams], found, num_rows, num_cols)
        {:right, ?\\} -> fire(contraption, [{i + 1, j, :down} | beams], found, num_rows, num_cols)
        {:right, ?| } -> fire(contraption, [{i - 1, j, :up}, {i + 1, j, :down}] ++ beams, found, num_rows, num_cols)
        {:right, _  } -> fire(contraption, [{i, j + 1, :right} | beams], found, num_rows, num_cols)

        {:up, ?/ } -> fire(contraption, [{i, j + 1, :right} | beams], found, num_rows, num_cols)
        {:up, ?\\} -> fire(contraption, [{i, j - 1, :left} | beams], found, num_rows, num_cols)
        {:up, ?- } -> fire(contraption, [{i, j + 1, :right}, {i, j - 1, :left}] ++ beams, found, num_rows, num_cols)
        {:up, _  } -> fire(contraption, [{i - 1, j, :up} | beams], found, num_rows, num_cols)

        {:left, ?/ } -> fire(contraption, [{i + 1, j, :down} | beams], found, num_rows, num_cols)
        {:left, ?\\} -> fire(contraption, [{i - 1, j, :up} | beams], found, num_rows, num_cols)
        {:left, ?| } -> fire(contraption, [{i + 1, j, :down}, {i - 1, j, :up}] ++ beams, found, num_rows, num_cols)
        {:left, _  } -> fire(contraption, [{i, j - 1, :left} | beams], found, num_rows, num_cols)
          
        {:down, ?/ } -> fire(contraption, [{i, j - 1, :left} | beams], found, num_rows, num_cols)
        {:down, ?\\} -> fire(contraption, [{i, j + 1, :right} | beams], found, num_rows, num_cols)
        {:down, ?- } -> fire(contraption, [{i, j - 1, :left}, {i, j + 1, :right}] ++ beams, found, num_rows, num_cols)
        {:down, _  } -> fire(contraption, [{i + 1, j, :down} | beams], found, num_rows, num_cols)
      end
    end
  end

  def energize(contraption, num_rows, num_cols) do
    fire(contraption, [{0, 0, :right}], MapSet.new(), num_rows, num_cols)
    |> Enum.reduce(MapSet.new(), fn {i, j, _}, energized ->
      MapSet.put(energized, {i, j})
    end)
  end
end

input =
  IO.stream()
  |> Enum.to_list()
  |> Enum.map(&String.trim_trailing/1)

num_rows = length(input)
num_cols = List.first(input) |> String.length()

Enum.with_index(input)
|> Enum.reduce(%{}, fn {line, i}, found ->
  String.trim(line)
  |> String.to_charlist()
  |> Enum.with_index()
  |> Enum.reduce(found, fn
    {?., _}, found -> found
    {obj, j}, found -> Map.put(found, {i, j}, obj)
  end)
end)
|> Beam.energize(num_rows, num_cols)
|> MapSet.size()
|> IO.puts()
