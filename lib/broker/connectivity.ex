defmodule Broker.Connectivity do
  @base_url Application.compile_env(:a_trading_system, :api_base_url)

  def create_repo(params) do
    IO.inspect(params)

    HTTPoison.post(@base_url <> "/repos", params, headers())
    |> handle_response
  end

  defp handle_response(resp) do
    case resp do
      {:ok, %{body: body, status_code: 200}} ->
        %{id: body.id, name: body.name}

      {:ok, %{body: body, status_code: 422}} ->
        %{error_message: body}
    end
  end

  defp headers do
    [{"Content-Type", "application/json"}]
  end
end
