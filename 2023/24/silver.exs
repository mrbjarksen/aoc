defmodule Pairs do
  def all([]), do: []

  def all([x | xs]) do
    with_x = Enum.map(xs, &{x, &1})
    without_x = all(xs)
    with_x ++ without_x
  end
end

IO.stream()
|> Enum.map(fn line ->
  [px, py, _, vx, vy, _] =
    Regex.scan(~r/(-?\d+)/, line, capture: :all_but_first)
    |> Enum.map(&String.to_integer(hd(&1)))

  {{px, py}, {vx, vy}}
end)
|> Pairs.all()
|> Enum.count(fn {{{px1, py1}, {vx1, vy1}}, {{px2, py2}, {vx2, vy2}}} ->
  {a, c} = {vy1 / vx1, py1 - vy1 / vx1 * px1}
  {b, d} = {vy2 / vx2, py2 - vy2 / vx2 * px2}

  if a == b do
    false
  else
    x = (d - c) / (a - b)
    y = a * x + c

    cond do
      (x - px1) * vx1 < 0 -> false
      (y - py1) * vy1 < 0 -> false
      (x - px2) * vx2 < 0 -> false
      (y - py2) * vy2 < 0 -> false
      x < 200_000_000_000_000 || x > 400_000_000_000_000 -> false
      y < 200_000_000_000_000 || y > 400_000_000_000_000 -> false
      true -> true
    end
  end
end)
|> IO.puts()
