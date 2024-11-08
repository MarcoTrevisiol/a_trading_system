defmodule Info.Day_number do
  def initial_value, do: 0
  def updated_value(value, %CandleStick{}), do: value + 1
end

defmodule Info.Close do
  def initial_value, do: nil
  def updated_value(_value, %CandleStick{close: close}), do: close
end

defmodule Trading.MarketState do
  defp atom_to_module(atom) do
    atom
    |> Atom.to_string()
    |> (fn s -> "Elixir.Info." <> String.capitalize(s) end).()
    |> String.to_atom()
  end

  def initial_state(queried_info) do
    queried_info
    |> Enum.map(fn i -> {i, atom_to_module(i).initial_value()} end)
    |> Enum.into(%{})
  end

  def query(state, info) do
    info
    |> Enum.map(fn i -> {i, Map.get(state, i)} end)
    |> Enum.into(%{})
  end

  def receive(state, %CandleStick{} = c) do
    state
    |> Enum.map(&update_value_in_state(&1, c))
    |> Enum.into(%{})
  end

  defp update_value_in_state({key, value}, c),
    do: {key, atom_to_module(key).updated_value(value, c)}
end
