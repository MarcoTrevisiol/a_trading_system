defmodule Trading.MarketState do
  @moduledoc """
  handler of info required by the tactics

  It keeps a state which must be initialized by initial_state and used as input for the other functions
  receive returns a state update
  query returns info as required by tactics
  """
  def initial_state(queried_info) do
    queried_info
    |> Stream.map(fn i -> {i, atom_to_module(i)} end)
    |> Stream.map(fn {i, info_module} -> {i, {info_module.initial_value(), info_module}} end)
    |> Enum.into(%{})
  end

  def query(state, info) do
    info
    |> Enum.map(fn i -> {i, Map.get(state, i) |> elem(0)} end)
    |> Enum.into(%{})
  end

  def receive(state, %CandleStick{} = c) do
    state
    |> Enum.map(&update_value_in_state(&1, c))
    |> Enum.into(%{})
  end

  defp atom_to_module(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> atom_to_module()
    |> String.to_atom()
  end

  defp atom_to_module(string) when is_binary(string),
    do: "Elixir.Trading.Info." <> Macro.camelize(string)

  defp update_value_in_state({key, {value, info_module}}, c),
    do: {key, {info_module.updated_value(value, c), info_module}}
end
