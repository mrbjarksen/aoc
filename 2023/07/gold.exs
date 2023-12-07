defmodule Cards do
  def card_value(card) do
    case card do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "T" -> 10
      "J" -> 0
      _ -> String.to_integer(card)
    end
  end

  def card_sort(card1, card2) do
    card_value(card1) <= card_value(card2)
  end

  def hand_type(hand) do
    freq = String.graphemes(hand) |> Enum.frequencies()
    {jokers, freq} = Map.pop(freq, "J", 0)

    if Enum.empty?(freq) do
      [5]
    else
      [max | rest] = freq |> Map.values() |> Enum.sort(&>=/2)
      [max + jokers | rest]
    end
  end

  def hand_sort(hand1, hand2) do
    type1 = hand_type(hand1)
    type2 = hand_type(hand2)

    if type1 == type2 do
      {card1, card2} =
        Enum.map([hand1, hand2], &String.graphemes/1)
        |> Enum.zip()
        |> Enum.find(fn {a, b} -> a != b end)

      card_sort(card1, card2)
    else
      type1 < type2
    end
  end
end

IO.stream()
|> Enum.map(&(String.trim(&1) |> String.split()))
|> Enum.sort_by(&List.first/1, &Cards.hand_sort/2)
|> Enum.map(&(List.last(&1) |> String.to_integer()))
|> Enum.with_index(fn bet, i -> (i + 1) * bet end)
|> Enum.sum()
|> IO.puts()
