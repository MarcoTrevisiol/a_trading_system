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

  test "net return of nothing is 0" do
    net_return =
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: [
            %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Trading.Tactic.Alternate}
          ]
        },
        data_source: []
      )

    assert net_return == 0
  end

  test "candlestick without adj and volume" do
    data_source =
      "test/one.csv"
      |> Trading.read_candlesticks!()
      |> Enum.at(0)

    assert data_source == %CandleStick{
             date: "Oct 30 2023",
             open: 0.5,
             high: 0.5,
             low: 0.5,
             close: 0.5
           }
  end

  test "candlestick with integer" do
    data_source =
      "test/zero.csv"
      |> Trading.read_candlesticks!()
      |> Enum.at(0)

    assert data_source == %CandleStick{
             date: "Oct 30 2023",
             open: 0,
             high: 0,
             low: 0,
             close: 0
           }
  end

  # @tag :skip
  test "work on real data" do
    prices_filename = "test/nq.csv"
    data_source = Trading.read_candlesticks!(prices_filename)

    net_return =
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: [
            %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Trading.Tactic.Alternate}
          ]
        },
        data_source: data_source
      )

    assert_in_delta(net_return, 398.0, 1.0e-4)
  end

  test "raise error on invalid data source" do
    invalid_data_source = "invalid"

    compute_fn = fn ->
      data_source = Trading.read_candlesticks!(invalid_data_source)
      data_source |> Enum.empty?()
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
