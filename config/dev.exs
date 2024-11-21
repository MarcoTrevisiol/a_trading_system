import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :a_trading_system, ATradingSystemWeb.Endpoint,
  code_reloader: true,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:a_trading_system, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:a_trading_system, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :a_trading_system, ATradingSystemWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/a_trading_system_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :debug

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
