defmodule ATradingSystemWeb.Controllers.HelloController do
  use ATradingSystemWeb, :controller

  def index(conn, params) do
    Broker.Connectivity.store_token()
    {:ok, content} = Broker.Connectivity.query("/info/trader")

    conn
    |> assign(:p, inspect(params))
    |> assign(:q, content)
    |> render("index.html")
  end
end
