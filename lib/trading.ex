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
      pending_orders: [],
      strategy: strategy,
      market_state: MarketState.initial_state(info_for_strategy),
      account_state: AccountState.initial_state()
    }

    data_source
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&parse_candlestick/1)
    |> Enum.reduce(initial_global_state, &reduce_step/2)
    |> Map.get(:account_state)
    |> Map.get(:usd)
  end

  defp reduce_step(
         candlestick,
         %{strategy: strategy, market_state: market_state, account_state: account_state} = state
       ) do
    IO.inspect(date: candlestick.date, close: candlestick.close)
    filled_orders = fill_orders(candlestick, state)
    next_account_state = AccountState.update(account_state, filled_orders)
    orders_from_filled = Strategy.handle_orders_filled(filled_orders, strategy)
    next_market_state = MarketState.receive(market_state, candlestick)
    orders_from_day_ended = Strategy.handle_day_ended(strategy, next_market_state)

    %{
      state
      | pending_orders: orders_from_filled ++ orders_from_day_ended,
        market_state: next_market_state,
        account_state: next_account_state
    }
  end

  defp fill_orders(candlestick, %{pending_orders: pending_orders}) do
    pending_orders
    |> Enum.map(&fill_order(&1, candlestick))
  end

  defp fill_order(%Trading.Orders.Market{quantity: quantity}, %CandleStick{close: close}) do
    %{filled_at: close, quantity: quantity}
  end

  defp parse_candlestick([date, open, high, low, close, _adj, _volume]) do
    %CandleStick{
      date: date,
      open: String.to_float(open),
      high: String.to_float(high),
      low: String.to_float(low),
      close: String.to_float(close)
    }
  end
end
