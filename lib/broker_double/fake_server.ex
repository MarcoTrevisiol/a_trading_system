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
end
