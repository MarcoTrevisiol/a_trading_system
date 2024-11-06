defmodule Trading.Tests do
  use ExUnit.Case

  test "process single event" do
    event = %Trading.Event.DayEnded{datetime: ~D[2024-01-01]}
    strategy = %Trading.Strategy{}
    _orders = Trading.process_event(event, strategy)
  end

  @tag :skip
  test "work on real data" do
    prices_filename = "test/nq.csv"

    net_return =
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Alternate}
        },
        data_source: prices_filename
      )

    assert net_return == 911.04
  end

  test "raise error on invalid data source" do
    invalid_data_source = "invalid"

    compute_fn = fn ->
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Alternate}
        },
        data_source: invalid_data_source
      )
    end

    assert_raise File.Error, compute_fn
  end
end
