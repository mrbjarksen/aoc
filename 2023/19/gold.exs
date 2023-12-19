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
end

defmodule Workflow do
  def combinations(workflows, [rule | rules], ranges) do
    %{x: {x_min, x_max}, m: {m_min, m_max}, a: {a_min, a_max}, s: {s_min, s_max}} = ranges

    current =
      (x_max - x_min + 1) * (m_max - m_min + 1) * (a_max - a_min + 1) * (s_max - s_min + 1)

    if current < 0 do
      0
    else
      case rule do
        :A ->
          current

        :R ->
          0

        rule when is_atom(rule) ->
          combinations(workflows, Map.get(workflows, rule), ranges)

        {category, :less, number, name} ->
          passed =
            combinations(
              workflows,
              [name | rules],
              Map.update!(ranges, category, fn {min, max} ->
                {min, min(max, number - 1)}
              end)
            )

          not_passed =
            combinations(
              workflows,
              rules,
              Map.update!(ranges, category, fn {min, max} ->
                {max(min, number), max}
              end)
            )

          passed + not_passed

        {category, :greater, number, name} ->
          passed =
            combinations(
              workflows,
              [name | rules],
              Map.update!(ranges, category, fn {min, max} ->
                {max(min, number + 1), max}
              end)
            )

          not_passed =
            combinations(
              workflows,
              rules,
              Map.update!(ranges, category, fn {min, max} ->
                {min, min(max, number)}
              end)
            )

          passed + not_passed
      end
    end
  end
end

IO.read(:all)
|> String.split("\n\n", trim: true)
|> Enum.map(&String.split(&1, "\n", trim: true))
|> List.first()
|> Enum.map(&Parse.workflow/1)
|> Map.new()
|> Workflow.combinations([:in], %{x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}})
|> IO.puts()
