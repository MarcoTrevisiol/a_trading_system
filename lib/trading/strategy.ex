defmodule Trading.Strategy do
  @moduledoc """
  A strategy is a recursively nested container for tactics.

  This module handle all possible events for a strategy.
  It also knows the info required by a strategy.
  """

  alias Trading.MarketState
  defstruct substrategies: []

  defmodule WeightedStrategy do
    @moduledoc """
    pair of a strategy and a weight for definition of weighted strategies

    if a substrategy is an atom, it is assumed to be a tactic, meaning:

    A Tactic is a basic build block for a Strategy, operating on a single security.

    It knows how to handle events to generate orders.
    It knows the info that requires to handle events.
    It knows its risk on a single unit of a security.
    """
    defstruct [:substrategy, weight: 1]
  end

  def handle_day_ended(%__MODULE__{substrategies: substrategies}, market_state) do
    substrategies
    |> Enum.flat_map(&handle_day_event(&1, market_state))
  end

  defp handle_day_event(%{substrategy: tactic}, market_state) do
    handle_tactic(tactic, market_state)
  end

  defp handle_tactic(tactic, market_state) when is_atom(tactic) do
    tactic.handle_event(
      %Trading.Event.DayEnded{},
      MarketState.query(market_state, tactic.info()),
      nil
    )
  end

  def handle_orders_filled(_filled_orders, %__MODULE__{}) do
    []
  end

  def info(%__MODULE__{substrategies: substrategies}) do
    substrategies
    |> Stream.map(&info_needed/1)
    |> Enum.reduce(&MapSet.union/2)
    |> Enum.to_list()
  end

  defp info_needed(%Trading.Strategy.WeightedStrategy{substrategy: substrategy}),
    do: info_needed(substrategy)

  defp info_needed(tactic) when is_atom(tactic),
    do: tactic.info() |> MapSet.new()
end
