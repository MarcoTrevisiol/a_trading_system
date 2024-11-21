defmodule Trading.Strategy do
  @moduledoc """
  A strategy is a recursively nested container for tactics.

  This module handle all possible events for a strategy.
  It also knows the info required by a strategy.
  """
  alias Trading.MarketState
  defstruct substrategies: []

  defmodule WeightedStrategy do
    @moduledoc "pair of a strategy and a weight for definition of weighted strategies"
    defstruct [:substrategy, weight: 1]
  end

  def handle_day_ended(%__MODULE__{substrategies: substrategies}, market_state) do
    substrategies
    |> Enum.flat_map(&handle_day_event(&1, market_state))
  end

  defp handle_day_event(%{substrategy: tactic}, market_state) do
    handle_tactic(tactic.tactic(), market_state)
  end

  defp handle_tactic(%Trading.Tactic{info: info, handle_event: handle_event}, market_state) do
    handle_event.(
      %Trading.Event.DayEnded{},
      MarketState.query(market_state, info),
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

  defp info_needed(%Trading.Strategy.WeightedStrategy{substrategy: substrategy}) do
    info_needed(substrategy.tactic())
  end

  defp info_needed(%Trading.Tactic{info: info}) do
    MapSet.new(info)
  end
end
