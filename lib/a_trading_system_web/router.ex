defmodule ATradingSystemWeb.Router do
  use ATradingSystemWeb, :router
  alias Controllers.{HelloController, PageController}
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ATradingSystemWeb.Components.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ATradingSystemWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/hello", HelloController, :index

    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    live_dashboard "/dashboard", metrics: ATradingSystemWeb.Telemetry
  end

  # Other scopes may use custom stacks.
  # scope "/api", ATradingSystemWeb do
  #   pipe_through :api
  # end
end
