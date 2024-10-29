# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :a_trading_system,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :a_trading_system, ATradingSystemWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  debug_errors: true,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ATradingSystemWeb.ErrorHTML, json: ATradingSystemWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ATradingSystem.PubSub,
  live_view: [signing_salt: "gM8h9+M5"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  a_trading_system: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  a_trading_system: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# FakeServer for test broker connectivity
config :a_trading_system, api_base_url: "http://localhost:8081"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
