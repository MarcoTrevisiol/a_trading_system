defmodule Broker.Connectivity do
  #
  #   __ ETS __
  #

  # Function to initialize the ETS table, making sure that it doesn't already exist

  defp init_ets do
    case :ets.whereis(:token_storage) do
      :undefined -> :ets.new(:token_storage, [:private, :set, :named_table])
      tid when is_reference(tid) -> tid
    end
  end

  # Function to retrieve the token stored using ETS

  defp get_token do
    case :ets.lookup(:token_storage, :token) do
      [{:token, token}] -> token
      [] -> nil
    end
  end

  #
  #   __ MISC __
  #

  # Function to handle http errors. In case of unauthorized requestes, calls the funcion store_token.

  def handle_http_error({:ok, %HTTPoison.Response{status_code: status_code}}) do
    case status_code do
      400 ->
        {:error, "400 Bad Request"}

      401 ->
        {:error, "401 Unauthorized - Token getting refreshed"}
        store_token()

      403 ->
        {:error, "403 Forbidden"}

      404 ->
        {:error, "404 Not Found (trader not found)"}

      406 ->
        {:error, "406 Not Acceptable"}

      429 ->
        {:error, "429 Too Many Requests"}

      500 ->
        {:error, "500 Internal Server Error"}

      _ ->
        {:error, "Unhandled HTTP error with status code #{status_code}"}
    end
  end

  def handle_http_error({:error, %HTTPoison.Error{reason: error_reason}}) do
    case error_reason do
      :nxdomain ->
        {:error, "Non Existent Domain"}

      :timeout ->
        {:error, "Timeout"}

      _ ->
        {:error, "HTTP request failed: #{inspect(error_reason)}"}
    end
  end

  # Function that return the headers for authorization using the token stored in the ET

  defp auth_head do
    [{"Authorization", ["Bearer ", get_token()]}]
  end

  # Function that return the Broker Endpoint

  defp endpoint, do: Application.fetch_env!(:a_trading_system, :broker_endpoint)

  #
  #   __ AUTHORIZATION __
  #

  # "Authorize to use the API" function, that stores the token using ETS

  def store_token do
    username = Application.fetch_env!(:a_trading_system, :broker_username)
    apiKey = Application.fetch_env!(:a_trading_system, :broker_api_key)

    payload = %{
      "Username" => to_string(username),
      "ApiKey" => to_string(apiKey)
    }

    body = Jason.encode!(payload)
    headers = [{"Content-Type", "application/json"}]

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

  def logout do
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

  def get_trader_info do
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

  def create_streamId do
    HTTPoison.get(endpoint() <> "/stream/create", auth_head())
  end

  # Client API

  def get_last_price(symbol) do
    init_ets()
    if get_token() == nil, do: {:ok, _} = store_token()
    result = get_quotes(symbol)

    case result do
      {:ok, %{"Quotes" => [%{"l" => last} | _]}} -> {:ok, last}
      _ -> result
    end
  end
end
