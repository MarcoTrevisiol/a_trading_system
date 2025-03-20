defmodule CandleStick do
  @moduledoc "A CandleStick aggregates prices in a bar"
  defstruct [:date, :open, :high, :low, :close]
end

defmodule Trading do
  @moduledoc """
  Main entry point.....
  """
  def process_event(_event, _strategy) do
  end

  alias NimbleCSV.RFC4180, as: CSV
  alias Trading.AccountState
  alias Trading.MarketState
  alias Trading.Strategy

  def compute_net_return(strategy: strategy, data_source: data_source) do
    info_for_strategy = Trading.Strategy.info(strategy)

    initial_global_state = %{
      pending_positions: [],
      strategy: strategy,
      market_state: MarketState.initial_state(info_for_strategy),
      account_state: AccountState.initial_state(),
      # the position for each tactic_id
      tactic_state: initial_tactic_state(strategy)
    }

    data_source
    |> Enum.reduce(initial_global_state, &reduce_step/2)
    |> Map.get(:account_state)
    |> Map.get(:usd)
  end

  defp initial_tactic_state(%Trading.Strategy{substrategies: weighted_strategies}) do
    weighted_strategies
    # TODO: let the id be more unique
    # (problem arises if the same Tactic is used more than once)
    |> Stream.map(fn %Trading.Strategy.WeightedStrategy{substrategy: substrategy} ->
      {substrategy, 0}
    end)
    |> Enum.into(%{})
  end

  def read_candlesticks!(filename) do
    filename
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&parse_candlestick/1)
  end

  defp reduce_step(
         candlestick,
         %{strategy: strategy, market_state: market_state, account_state: account_state} = state
       ) do
    pending_orders = convert_positions_to_orders(state)
    filled_orders = fill_orders(candlestick, pending_orders)
    next_account_state = AccountState.update(account_state, filled_orders)
    positions_from_filled = Strategy.handle_orders_filled(filled_orders, strategy)
    next_market_state = MarketState.receive(market_state, candlestick)
    positions_from_day_ended = Strategy.handle_day_ended(strategy, next_market_state)
    next_tactic_state = update_tactic_state(state, filled_orders)

    %{
      state
      | pending_positions: positions_from_filled ++ positions_from_day_ended,
        market_state: next_market_state,
        account_state: next_account_state,
        tactic_state: next_tactic_state
    }
  end

  defp convert_positions_to_orders(%{
         pending_positions: pending_positions,
         tactic_state: tactic_state
       }) do
    pending_positions
    |> Enum.map(&convert_position_to_order(&1, tactic_state))
  end

  defp convert_position_to_order(
         %Trading.Positions.Market{position: position, tactic_id: tactic_id} = trading_position,
         tactic_state
       ) do
    current_position = Map.fetch!(tactic_state, tactic_id)

    %{
      order: %Trading.Orders.Market{quantity: position - current_position},
      position: trading_position
    }
  end

  defp fill_orders(candlestick, pending_orders) do
    pending_orders
    |> Enum.map(&fill_order(&1, candlestick))
  end

  defp fill_order(
         %{order: %Trading.Orders.Market{quantity: quantity}, position: position},
         %CandleStick{open: open}
       ) do
    %{filled_at: open, quantity: quantity, position: position}
  end

  defp update_tactic_state(%{tactic_state: tactic_state}, filled_orders) do
    filled_orders
    |> Enum.reduce(tactic_state, &reduce_tactic_state/2)
  end

  defp reduce_tactic_state(%{position: %{tactic_id: tactic_id, position: position}}, tactic_state) do
    tactic_state
    |> Map.put(tactic_id, position)
  end

  defp parse_candlestick([date, open, high, low, close | _rest]) do
    %CandleStick{
      date: date,
      open: parse_float(open),
      high: parse_float(high),
      low: parse_float(low),
      close: parse_float(close)
    }
  end

  defp parse_float(str) do
    case Float.parse(str) do
      {num, _} -> num
      :error -> raise "Error parsing number: #{inspect(str)}"
    end
  end
end
