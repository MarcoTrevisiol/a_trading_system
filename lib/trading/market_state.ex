defmodule Trading.Info.DayNumber do
  @moduledoc "info for incremental day number"
  def initial_value, do: 0
  def updated_value(value, %CandleStick{}), do: value + 1
end

defmodule Trading.Info.Close do
  @moduledoc "info for last close price of a security"
  def initial_value, do: nil
  def updated_value(_value, %CandleStick{close: close}), do: close
end

defmodule Trading.MarketState do
  @moduledoc """
  handler of info required by the tactics

  It keeps a state which must be initialized by initial_state and used as input for the other functions
  receive returns a state update
  query returns info as required by tactics
  """
  defp atom_to_module(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> atom_to_module()
    |> String.to_atom()
  end

  defp atom_to_module(string) when is_binary(string) do
    "Elixir.Trading.Info." <> Macro.camelize(string)
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
