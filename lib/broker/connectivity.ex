defmodule Broker.Connectivity do
  @base_url Application.compile_env(:a_trading_system, :api_base_url)

  def create_repo(params) do
    HTTPoison.post(@base_url <> "/repos", Jason.encode!(params), headers())
    |> handle_response
  end

  defp handle_response(resp) do
    case resp do
      {:ok, %{body: body, status_code: 200}} ->
        body_map = Jason.decode!(body)
        %{id: body_map["id"], name: body_map["name"]}

      {:ok, %{body: body, status_code: 422}} ->
        body_map = Jason.decode!(body)
        %{error_message: body_map["message"]}
    end
  end

  defp headers do
    [{"Content-Type", "application/json"}]
  end
end
