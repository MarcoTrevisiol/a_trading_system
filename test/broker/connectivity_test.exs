defmodule Broker.ConnectivityTest do
  use ExUnit.Case, async: false

  setup do
    start_supervised(
      {Plug.Cowboy, scheme: :http, plug: BrokerDouble.FakeServer, options: [port: 8081]}
    )

    :ok
  end

  # @tag :skip
  test "get quotes with wrong symbol returns error" do
    {:error, _reason} = Broker.Connectivity.get_last_price("WRONG:SYMBOL")
  end

  # @tag :skip
  test "get quotes returns quotes" do
    {:ok, price} = Broker.Connectivity.get_last_price("XCME:6E")
    assert is_float(price)
  end
end
