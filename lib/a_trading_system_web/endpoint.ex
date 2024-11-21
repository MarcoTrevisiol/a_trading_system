defmodule ATradingSystemWeb.Endpoint do
  use SiteEncrypt.Phoenix.Endpoint, otp_app: :a_trading_system

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_a_trading_system_key",
    signing_salt: "0W78n9N/",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :a_trading_system,
    gzip: false,
    only: ATradingSystemWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ATradingSystemWeb.Router

  @impl SiteEncrypt
  def certification do
    endpoint_config = Application.fetch_env!(:a_trading_system, ATradingSystemWeb.Endpoint)
    cert_mode = Keyword.fetch!(endpoint_config, :cert_mode)
    domain = Keyword.fetch!(endpoint_config, :domain)
    email = Keyword.fetch!(endpoint_config, :email)
    http_port = Keyword.fetch!(endpoint_config, :http) |> Keyword.fetch!(:port)

    # port used for CA server in "local" cert mode; I do not want another variable for this one,
    # but I need differnt ports for different instances of the trading system
    local_ca_port = http_port + 4000
    server? = Keyword.get(endpoint_config, :server, false)

    SiteEncrypt.configure(
      # Note that native client is very immature. If you want a more stable behaviour, you can
      # provide `:certbot` instead. Note that in this case certbot needs to be installed on the
      # host machine.
      client: :native,
      # auto mode is active only if server is started (usually not in dev)
      mode: if(server?, do: :auto, else: :manual),
      domains: [domain],
      emails: [email],

      # By default the certs will be stored in tmp/site_encrypt_db, which is convenient for
      # local development. Make sure that tmp folder is gitignored.
      #
      # Set OS env var SITE_ENCRYPT_DB on staging/production hosts to some absolute path
      # outside of the deployment folder. Otherwise, the deploy may delete the db_folder,
      # which will effectively remove the generated key and certificate files.
      db_folder: "priv/site_encrypt_db",

      # set OS env var CERT_MODE to "staging" or "production" on staging/production hosts
      directory_url:
        case(cert_mode) do
          "local" -> {:internal, port: local_ca_port}
          "staging" -> "https://acme-staging-v02.api.letsencrypt.org/directory"
          "production" -> "https://acme-v02.api.letsencrypt.org/directory"
        end
    )
  end
end
