defmodule BrokerDouble.FakeServer do
  @moduledoc "Fake server for testing broker connectivity"
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  #
  #   __ Authorisation __
  #

  # "Authorize to use the API" responses

  @success_body %{
    "token" => "eyJ0eXAiOiJKV1QiLCJhbGciOiJSU",
    "status" => "OK",
    "message" => "string"
  }
  @failure_body %{
    "status" => "ERROR",
    "message" => "Error message",
    "error" => "Missing username or password"
  }

  post "/auth" do
    case conn.params do
      %{} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(@success_body))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(@failure_body))
    end
  end

  # "Logout user" responses

  @logout_data %{
    "status" => "OK",
    "message" => "OK"
  }
  post "/logout" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(@logout_data))
  end

  #
  #   __ INFO __
  #

  @trader_data %{
    "status" => "OK",
    "message" => "OK",
    "accounts" => [
      "5123345",
      "5123346",
      "5123347"
    ],
    "isLive" => true,
    "traderId" => "5123345"
  }
  get "/info/trader" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(@trader_data))
  end

  #
  #   __ STREAMING __
  #

  @streamid "123e4567-e89b-12d3-a456-426614174000"

  # "Create a streamId" responses

  @create_stream_data %{
    "streamId" => @streamid,
    "status" => "OK",
    "message" => "String"
  }

  get "/stream/create" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(@create_stream_data))
  end

  # "Subscribe to quotes" responses

  @subscribe_quotes_data %{
    "status" => "OK",
    "message" => "OK"
  }

  get "/market/quotes/subscribe/#{@streamid}" do
    case conn.query_params do
      %{"symbols" => _} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(@subscribe_quotes_data))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{}))
    end
  end

  # "Subscribe to depths" responses

  @subscribe_depths_data %{
    "status" => "OK",
    "message" => "OK"
  }

  get "/market/depths/subscribe/#{@streamid}" do
    case conn.query_params do
      %{"symbols" => _} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(@subscribe_depths_data))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{}))
    end
  end

  # "Subscribe to trades" responses

  @subscribe_trades_data %{
    "status" => "OK",
    "message" => "OK"
  }

  get "/market/trades/subscribe/#{@streamid}" do
    case conn.query_params do
      %{"symbols" => _} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(@subscribe_trades_data))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{}))
    end
  end

  #
  #   __ MARKET __
  #

  @market_data %{
    "Quotes" => [%{s: "XCME:6E", l: 1000.0}],
    "status" => "OK",
    "message" => "String"
  }

  get "/market/quotes" do
    case conn.query_params do
      %{"symbols" => "XCME:6E"} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(@market_data))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{}))
    end
  end
end
