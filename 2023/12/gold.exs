defmodule Springs do
  def possibilities(spring, groups, cached \\ %{})

  def possibilities([], [], cached), do: {1, cached}

  def possibilities(springs, [], cached) do
    if Enum.all?(springs, &(&1 != :damaged)), do: {1, cached}, else: {0, cached}
  end

  def possibilities([:operational | springs], groups, cached) do
    possibilities(springs, groups, cached)
  end

  def possibilities(springs, groups, cached) do
    case Map.get(cached, {springs, groups}) do
      nil ->
        {group, rest} = Enum.split(springs, hd(groups))

        cond do
          length(group) < hd(groups) ->
            {0, cached}

          Enum.any?(group, &(&1 == :operational)) ->
            case group do
              [:damaged | _] -> {0, cached}
              _ -> possibilities(tl(springs), groups, cached)
            end

          hd(group) == :damaged ->
            case rest do
              [] -> possibilities([], tl(groups), cached)
              [:damaged | _] -> {0, cached}
              [_ | rest] -> possibilities(rest, tl(groups), cached)
            end

          hd(group) == :unknown ->
            case rest do
              [] ->
                possibilities([], tl(groups), cached)

              [:damaged | _] ->
                possibilities(tl(springs), groups, cached)

              [_ | rest] ->
                {chosen, cached} = possibilities(rest, tl(groups), cached)
                {continued, cached} = possibilities(tl(springs), groups, cached)
                {chosen + continued, Map.put(cached, {springs, groups}, chosen + continued)}
            end
        end

      total ->
        {total, cached}
    end
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

  springs = Enum.map(1..5, fn _ -> springs end) |> Enum.intersperse([:unknown]) |> Enum.concat()
  groups = Enum.flat_map(1..5, fn _ -> groups end)

  Springs.possibilities(springs, groups)
  |> elem(0)
end)
|> Enum.sum()
|> IO.puts()
