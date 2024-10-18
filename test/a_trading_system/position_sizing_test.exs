defmodule PositionSizing.Tests do
  use ExUnit.Case

  test "single market compute number of contracts" do
    account_balance = 1000
    expected_loss = 10
    allocation_strategy = 0.02

    assert PositionSizing.number_of_contracts(account_balance, expected_loss, allocation_strategy) ==
             2

    strategy_1 = %{
      info_needed: [:parity_of_the_day],
      parameters: %{},
      strategy_module: LongOrShort
    }

    strategy_2 = %{
      info_needed: [:variation_of_yesterday],
      parameters: %{threshold: 0.01},
      strategy_module: LongOrFlat
    }

    _portfolio = %{
      strategy_1 => 0.07,
      strategy_2 => 0.02
    }
  end
end
