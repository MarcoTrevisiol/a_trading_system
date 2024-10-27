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

  defp endpoint, do: System.get_env("BROKER_ENDPOINT")

  #
  #   __ ETS __
  #

  # Function to initialize the ETS table, making sure that it doesn't already exist

  defp init_ets() do
    case :ets.whereis(:token_storage) do
      :undefined -> :ets.new(:token_storage, [:private, :set, :named_table])
      tid when is_reference(tid) -> tid
    end
  end

  # Function to retrieve the token stored using ETS

  defp get_token() do
    case :ets.lookup(:token_storage, :token) do
      [{:token, token}] -> IO.inspect(token)
      [] -> nil
    end
  end

  #
  #   __ MISC __
  #

  # Function that return the headers for authorization using the token stored in the ET

  defp auth_head() do
    [{"Authorization", ["Bearer ", get_token()]}]
  end

  #
  #   __ AUTHORIZATION __
  #

  # "Authorize to use the API" function, that stores the token using ETS

  def store_token() do
    username = System.get_env("USERNAME")
    apiKey = System.get_env("API_KEY")

    payload = %{
      "Username" => to_string(username),
      "ApiKey" => to_string(apiKey)
    }

    body = Jason.encode!(payload)
    headers = [{"Content-Type", "application/json"}]

    IO.inspect({endpoint() <> "/auth", body, headers})
    # Make HTTP request
    with {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} <-
           HTTPoison.post(endpoint() <> "/auth", body, headers),
         {:ok, %{"token" => token}} <-
           Jason.decode(response_body) do
      init_ets()
      :ets.insert(:token_storage, {:token, token})
      {:ok, "Token stored successfully"}
    end
  end

  # "Logout user" function

  defp logout() do
    case HTTPoison.post(endpoint() <> "/logout", auth_head()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"status" => "OK", "message" => "OK"}} ->
            {:ok, "Logout successful"}

          {:ok, _unexpected_response} ->
            {:error, "Unexpected response format"}

          {:error, _decode_error} ->
            {:error, "Failed to parse response body"}
        end

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "Unexpected status code: #{code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  #
  #   __ INFO __
  #

  # "Get trader info" function

  defp get_trader_info() do
    url = "#{endpoint()}/info/trader"

    case HTTPoison.get(url, auth_head()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch balance. Status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  #
  #   __ ACCOUNT __
  #

  # "Get account balance" function

  def get_account_balance(account_id, balance_type) do
    url = "#{endpoint()}/account/#{account_id}/balance?q=#{balance_type}"

    case HTTPoison.get(url, auth_head()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch balance. Status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  #
  #   __ MARKET __
  #

  # "Get quotes" function

  defp get_quotes(quotes) do
    query_params = URI.encode_query(%{"symbols" => quotes})
    url = "#{endpoint()}/market/quotes?#{query_params}"

    case HTTPoison.get(url, auth_head()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} ->
            {:ok, decoded_body}

          {:error, error} ->
            {:error, "Failed to decode JSON: #{error}"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Request failed with status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  #
  #   __ STREAMING __
  #

  # "Create a streamId" function

  def create_streamId() do
    HTTPoison.get(endpoint() <> "/stream/create", auth_head())
  end

  # Client API

  def get_last_price(symbol) do
    init_ets()
    if get_token() == nil, do: {:ok, _} = store_token()
    # IO.inspect(x)
    IO.inspect(get_token())
    result = get_quotes(symbol)
    IO.inspect(result)

    case result do
      {:ok, %{"Quotes" => [%{"l" => last} | _]}} -> {:ok, last}
      _ -> result
    end
  end
end
