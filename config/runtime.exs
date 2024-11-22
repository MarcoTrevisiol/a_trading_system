import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/a_trading_system start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :a_trading_system, ATradingSystemWeb.Endpoint, server: true
end

https_port = String.to_integer(System.fetch_env!("HTTPS_PORT"))
http_port = String.to_integer(System.fetch_env!("HTTP_PORT"))

config :a_trading_system, ATradingSystemWeb.Endpoint,
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  http: [port: http_port],
  https: [port: https_port],
  cert_mode: System.fetch_env!("CERT_MODE"),
  domain: System.fetch_env!("CERT_DOMAIN"),
  email: System.fetch_env!("CERT_EMAIL")

config :a_trading_system,
  broker_endpoint: System.fetch_env!("BROKER_ENDPOINT"),
  broker_username: System.fetch_env!("USERNAME"),
  broker_api_key: System.fetch_env!("API_KEY"),
  web_username: "admin",
  web_password: System.fetch_env!("WEB_PASSWORD")
