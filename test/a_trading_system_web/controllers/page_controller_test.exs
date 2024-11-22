defmodule ATradingSystemWeb.Controllers.PageControllerTest do
  use Support.ConnCase

  test "GET /", %{conn: conn} do
    username = Application.fetch_env!(:a_trading_system, :web_username)
    password = Application.fetch_env!(:a_trading_system, :web_password)

    conn =
      conn
      |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth(username, password))
      |> get(~p"/")

    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end

  test "error when no credentials are supplied", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert conn.status == 401
  end

  test "error when credentials are invalid", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth("admin", "wrong"))
      |> get(~p"/")

    assert conn.status == 401
  end
end
