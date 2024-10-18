defmodule Broker.ConnectivityTest do
  use ExUnit.Case, async: false

  @success_repo_params %{name: "success-repo"}
  @failure_repo_params %{name: "failed-repo"}

  test "create_repo when success" do
    response = Broker.Connectivity.create_repo(@success_repo_params)
    assert response == :ok

    # assert %{name: "success-repo"} == response
  end

  test "create_repo when failure" do
    response = Broker.Connectivity.create_repo(@failure_repo_params)
    assert %{error_message: "error message"} == response
  end
end
