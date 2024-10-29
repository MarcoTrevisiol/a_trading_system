defmodule ATradingSystem.MixProject do
  use Mix.Project

  def project do
    [
      app: :a_trading_system,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [a_trading_system: [include_executable_for: [:unix]]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ATradingSystem.Application, []},
      extra_applications: [:logger, :runtime_tools, :cowboy]
    ]
  end

  # defp applications(:test), do: applications(:default) ++ [:httpoison, :cowboy]
  # defp applications(_), do: applications(:default) ++ [:httpoison]

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix deps

      {:phoenix, "~> 1.7.14"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},

      # Deployment support for SystemD deps
      {:mix_systemd, "~> 0.1", only: :dev},

      # HTTP Request deps
      {:httpoison, "~> 2.0"},

      # Mock Server deps
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind a_trading_system", "esbuild a_trading_system"],
      "assets.deploy": [
        "tailwind a_trading_system --minify",
        "esbuild a_trading_system --minify",
        "phx.digest"
      ]
    ]
  end
end
