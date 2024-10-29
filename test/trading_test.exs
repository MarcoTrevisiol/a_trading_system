defmodule Trading.Tests do
  use ExUnit.Case

  test "process single event" do
    event = %Trading.Event.DayEnded{datetime: ~D[2024-01-01]}
    strategy = %Trading.Strategy{}
    orders = Trading.process_event(event, strategy)
  end

  test "work on real data" do
    prices_filename = "nq.csv"

    net_return =
      Trading.compute_net_return(
        strategy: %Trading.Strategy{
          substrategies: %Trading.Strategy.WeightedStrategy{weight: 1, substrategy: Alternate}
        },
        data_source: prices_filename
      )

    assert net_return == 0.1
  end
end
