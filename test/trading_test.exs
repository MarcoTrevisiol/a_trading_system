defmodule TradingTest do
  use ExUnit.Case

  test "process single event" do
    event = %Trading.Event.DayEnded{datetime: ~D[2024-01-01]}
    strategy = %Trading.Strategy{}
    _orders = Trading.process_event(event, strategy)
  end

  test "marketplace knows day number" do
    info_queried = [:day_number]
    initial_state = Trading.MarketState.initial_state(info_queried)
    info = Trading.MarketState.query(initial_state, info_queried)
    assert info == %{day_number: 0}

    candlestick = %CandleStick{}
    state = Trading.MarketState.receive(initial_state, candlestick)
    info = Trading.MarketState.query(state, info_queried)
    assert info == %{day_number: 1}
  end

  test "marketplace knows last close" do
    info_queried = [:close]
    initial_state = Trading.MarketState.initial_state(info_queried)
    info = Trading.MarketState.query(initial_state, info_queried)
    assert info == %{close: nil}

    candlestick = %CandleStick{close: 57}
    state = Trading.MarketState.receive(initial_state, candlestick)
    info = Trading.MarketState.query(state, info_queried)
    assert info == %{close: 57}
  end

  @tag :skip
  test "work on real data" do
    prices_filename = "test/nq.csv"

    net_return =
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: [
            %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Trading.Tactic.Alternate}
          ]
        },
        data_source: prices_filename
      )

    assert net_return == -455.52
  end

  test "raise error on invalid data source" do
    invalid_data_source = "invalid"

    compute_fn = fn ->
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: [
            %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Trading.Tactic.Alternate}
          ]
        },
        data_source: invalid_data_source
      )
    end

    assert_raise File.Error, compute_fn
  end

  test "strategy knows info of its tactics" do
    strategy = %Trading.Strategy{
      substrategies: [
        %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Trading.Tactic.Alternate}
      ]
    }

    assert Trading.Strategy.info(strategy) == [:day_number]
  end
end
