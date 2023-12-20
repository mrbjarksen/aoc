defmodule Machine do
  def pulse(modules, pulses, counts \\ %{low: 0, high: 0})

  def pulse(modules, [], counts), do: {modules, counts}

  def pulse(modules, [{from, pulse, to} | pulses], counts) do
    counts = Map.update!(counts, pulse, &(&1 + 1))

    case {pulse, Map.get(modules, to)} do
      {:low, {:flipflop, :off, next}} ->
        modules = Map.put(modules, to, {:flipflop, :on, next})
        new_pulses = Enum.map(next, &{to, :high, &1})
        pulse(modules, pulses ++ new_pulses, counts)

      {:low, {:flipflop, :on, next}} ->
        modules = Map.put(modules, to, {:flipflop, :off, next})
        new_pulses = Enum.map(next, &{to, :low, &1})
        pulse(modules, pulses ++ new_pulses, counts)

      {:high, {:flipflop, _, _}} ->
        pulse(modules, pulses, counts)

      {_, {:conjunction, memory, next}} ->
        memory = %{memory | from => pulse}
        modules = Map.put(modules, to, {:conjunction, memory, next})
        new_pulse = if Enum.all?(memory, fn {_, type} -> type == :high end), do: :low, else: :high
        new_pulses = Enum.map(next, &{to, new_pulse, &1})
        pulse(modules, pulses ++ new_pulses, counts)

      {_, {_, _, next}} ->
        new_pulses = Enum.map(next, &{to, pulse, &1})
        pulse(modules, pulses ++ new_pulses, counts)
    end
  end
end

modules =
  IO.stream()
  |> Enum.reduce(%{}, fn line, modules ->
    [from | to] = Regex.scan(~r/[a-z]+/, line) |> Enum.concat() |> Enum.map(&String.to_atom/1)

    modules =
      Enum.reduce(to, modules, fn name, modules ->
        if Map.has_key?(modules, name) do
          modules
        else
          Map.put(modules, name, {:untyped, nil, []})
        end
      end)

    case String.first(line) do
      "b" -> Map.put(modules, from, {:broadcaster, nil, to})
      "%" -> Map.put(modules, from, {:flipflop, :off, to})
      "&" -> Map.put(modules, from, {:conjunction, %{}, to})
    end
  end)

modules =
  Enum.reduce(modules, modules, fn {sender, {_, _, sendees}}, modules ->
    Enum.reduce(sendees, modules, fn sendee, modules ->
      Map.update!(modules, sendee, fn
        {:conjunction, memory, next} -> {:conjunction, Map.put(memory, sender, :low), next}
        module -> module
      end)
    end)
  end)

{_, %{low: low, high: high}} =
  Enum.reduce(1..1000, {modules, %{low: 0, high: 0}}, fn _, {modules, counts} ->
    Machine.pulse(modules, [{:button, :low, :broadcaster}], counts)
  end)

IO.puts(low * high)
