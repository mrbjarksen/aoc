defmodule Machine do
  def pulse(modules, pulses, to_count \\ :rx, counts \\ %{low: 0, high: 0})

  def pulse(modules, [], _, counts), do: {modules, counts}

  def pulse(modules, [{from, pulse, to} | pulses], to_count, counts) do
    counts = if to == to_count, do: Map.update!(counts, pulse, &(&1 + 1)), else: counts

    case {pulse, Map.get(modules, to)} do
      {:low, {:flipflop, :off, next}} ->
        modules = Map.put(modules, to, {:flipflop, :on, next})
        new_pulses = Enum.map(next, &{to, :high, &1})
        pulse(modules, pulses ++ new_pulses, to_count, counts)

      {:low, {:flipflop, :on, next}} ->
        modules = Map.put(modules, to, {:flipflop, :off, next})
        new_pulses = Enum.map(next, &{to, :low, &1})
        pulse(modules, pulses ++ new_pulses, to_count, counts)

      {:high, {:flipflop, _, _}} ->
        pulse(modules, pulses, to_count, counts)

      {_, {:conjunction, memory, next}} ->
        memory = %{memory | from => pulse}
        modules = Map.put(modules, to, {:conjunction, memory, next})
        new_pulse = if Enum.all?(memory, fn {_, type} -> type == :high end), do: :low, else: :high
        new_pulses = Enum.map(next, &{to, new_pulse, &1})
        pulse(modules, pulses ++ new_pulses, to_count, counts)

      {_, {_, _, next}} ->
        new_pulses = Enum.map(next, &{to, pulse, &1})
        pulse(modules, pulses ++ new_pulses, to_count, counts)
    end
  end

  def count_until_low(modules, input, output, count \\ 0) do
    {modules, counts} = pulse(modules, [{nil, :low, input}], output)
    count = count + 1

    if counts.low == 1 do
      count
    else
      count_until_low(modules, input, output, count)
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

# Inspection of input data shows that the machine is split into
# four binary counters consisting of a cycle of twelve flip-flop modules.
# The end of each cycle sends a single low pulse with a regular
# interval, and rx recieves a single low pulse when all of these
# cycles send a signle low pulse simultaneously.
# Thus, the number of button presses needed is equal to
# the product of the counter values..

inputs = Map.get(modules, :broadcaster) |> elem(2)

outputs =
  Enum.map(inputs, fn start ->
    [left, right] = Map.get(modules, start) |> elem(2)
    output = if start in (Map.get(modules, left) |> elem(2)), do: left, else: right

    Enum.find(Map.get(modules, output) |> elem(2), fn name ->
      {type, _, _} = Map.get(modules, name)
      type == :conjunction
    end)
  end)

Enum.zip_with(inputs, outputs, &Machine.count_until_low(modules, &1, &2))
|> Enum.product()
|> IO.puts()
