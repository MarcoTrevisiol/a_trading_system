defmodule BrokerDouble.FakeServer do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  post "/repos" do
    case conn.params do
      %{"name" => "success-repo"} ->
        success(conn, %{"id" => 1234, "name" => "success-repo"})

      %{"name" => "failed-repo"} ->
        failure(conn)
    end
  end

  defp success(conn, body) do
    conn
    |> Plug.Conn.send_resp(200, Jason.encode!(body))
  end

  defp failure(conn) do
    conn
    |> Plug.Conn.send_resp(422, Jason.encode!(%{message: "error message"}))
  end

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
      %{"username" => "username", "password" => "password", "apikey" => "apikey"} ->
        Plug.Conn.send_resp(conn, 200, Jason.encode!(@success_body))

      _ ->
        Plug.Conn.send_resp(conn, 400, Jason.encode!(@failure_body))
    end
  end

  # "Logout user" responses

  @logout_data %{
    "status" => "OK",
    "message" => "OK"
  }
  post "/logout" do
    Plug.Conn.send_resp(conn, 200, Jason.encode!(@logout_data))
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
    Plug.Conn.send_resp(conn, 200, Jason.encode!(@trader_data))
  end

  #
  #   __ STREAMING __
  #

  # Response to create a new Stream

  @create_data %{
    "streamId" => "123e4567-e89b-12d3-a456-426614174000",
    "status" => "OK",
    "message" => "String"
  }

  get "/stream/create" do
    Plug.Conn.send_resp(conn, 200, Jason.encode!(@create_data))
  end
end
