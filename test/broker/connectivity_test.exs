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

  # @tag :skip
  test "create_repo when success" do
    response = Broker.Connectivity.create_repo(@success_repo_params)

    assert response == %{name: "success-repo", id: 1234}
  end

  test "create_repo when failure" do
    response = Broker.Connectivity.create_repo(@failure_repo_params)
    assert response == %{error_message: "error message"}
  end
end
