defmodule ATradingSystemWeb.EndpointTest do
  use ExUnit.Case, async: false
  import SiteEncrypt.Phoenix.Test

  test "certification" do
    clean_restart(ATradingSystemWeb.Endpoint)
    cert = get_cert(ATradingSystemWeb.Endpoint)
    domain = System.fetch_env!("CERT_DOMAIN")
    assert cert.domains == [domain]
  end
end
