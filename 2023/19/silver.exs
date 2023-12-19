defmodule Parse do
  def workflow(line) do
    [name, rules] =
      String.trim(line)
      |> String.replace_suffix("}", "")
      |> String.split("{", parts: 2)

    rules =
      String.split(rules, ",")
      |> Enum.map(fn rule ->
        case Regex.run(~r/([xmas])([<>])(\d+):([a-z]+|A|R)/, rule, capture: :all_but_first) do
          [category, "<", number, name] ->
            {String.to_atom(category), :less, String.to_integer(number), String.to_atom(name)}

          [category, ">", number, name] ->
            {String.to_atom(category), :greater, String.to_integer(number), String.to_atom(name)}

          nil ->
            String.to_atom(rule)
        end
      end)

    {String.to_atom(name), rules}
  end

  def part(line) do
    [[x], [m], [a], [s]] = Regex.scan(~r/\d+/, line)
    [x, m, a, s] = Enum.map([x, m, a, s], &String.to_integer/1)
    %{:x => x, :m => m, :a => a, :s => s}
  end
end

defmodule Workflow do
  def pass(workflows, name, part) do
    passed =
      Map.get(workflows, name)
      |> Enum.find(fn
        {category, :less, number, _} -> Map.get(part, category) < number
        {category, :greater, number, _} -> Map.get(part, category) > number
        _ -> true
      end)

    passed =
      case passed do
        {_, _, _, passed} -> passed
        passed -> passed
      end

    case passed do
      :A -> :A
      :R -> :R
      next -> pass(workflows, next, part)
    end
  end
end

[workflows, parts] =
  IO.read(:all)
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.split(&1, "\n", trim: true))

workflows =
  Enum.map(workflows, &Parse.workflow/1)
  |> Map.new()

parts = Enum.map(parts, &Parse.part/1)

Enum.filter(parts, &(Workflow.pass(workflows, :in, &1) == :A))
|> Enum.flat_map(&Map.values/1)
|> Enum.sum()
|> IO.puts()
