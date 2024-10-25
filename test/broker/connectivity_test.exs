defmodule Broker.ConnectivityTest do
  use ExUnit.Case, async: false

  @success_repo_params %{name: "success-repo"}
  @failure_repo_params %{name: "failed-repo"}

  setup do
    start_supervised(
      {Plug.Cowboy, scheme: :http, plug: BrokerDouble.FakeServer, options: [port: 8081]}
    )

    :ok
  end

  @tag :skip
  test "create_repo when success" do
    response = Broker.Connectivity.create_repo(@success_repo_params)

    assert response == %{name: "success-repo", id: 1234}
  end

  @tag :skip
  test "create_repo when failure" do
    response = Broker.Connectivity.create_repo(@failure_repo_params)
    assert response == %{error_message: "error message"}
  end

  # @tag :skip
  test "get quotes with wrong symbol returns error" do
    {:error, _reason} = Broker.Connectivity.get_last_price("WRONG:SYMBOL")
  end

  @tag :skip
  test "get quotes returns quotes" do
    {:ok, price} = Broker.Connectivity.get_last_price("XCME:ES.U16")
    assert is_float(price)
  end
end
