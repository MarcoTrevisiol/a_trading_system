defmodule CandleStick do
  defstruct [:date, :open, :high, :low, :close]
end

defmodule Trading do
  def process_event(_event, _strategy) do
  end

  alias Trading.MarketState
  alias Trading.Strategy
  alias NimbleCSV.RFC4180, as: CSV

  def compute_net_return(strategy: strategy, data_source: data_source) do
    info_for_strategy = Trading.Strategy.info(strategy)

    initial_global_state = %{
      pending_orders: [],
      strategy: strategy,
      market_state: MarketState.initial_state(info_for_strategy)
    }

    data_source
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&parse_candlestick/1)
    |> Enum.reduce(initial_global_state, &reduce_step/2)
    |> IO.inspect()
  end

  defp reduce_step(candlestick, %{strategy: strategy, market_state: market_state} = state) do
    filled_orders = fill_orders(candlestick, state)
    orders_from_filled = Strategy.handle_orders_filled(filled_orders, strategy)
    next_market_state = MarketState.receive(market_state, candlestick)
    orders_from_day_ended = Strategy.handle_day_ended(strategy, next_market_state)

    %{
      state
      | pending_orders: orders_from_filled ++ orders_from_day_ended,
        market_state: next_market_state
    }
  end

  defp fill_orders(candlestick, %{pending_orders: pending_orders}) do
    pending_orders
    |> Stream.map(&fill_order(&1, candlestick))
  end

  defp fill_order(_order, %CandleStick{open: open}) do
    %{filled_at: open}
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
