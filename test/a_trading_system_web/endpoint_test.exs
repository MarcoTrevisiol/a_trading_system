defmodule ATradingSystemWeb.Endpoint.Test do
  use ExUnit.Case, async: false
  import SiteEncrypt.Phoenix.Test

  test "certification" do
    clean_restart(ATradingSystemWeb.Endpoint)
    cert = get_cert(ATradingSystemWeb.Endpoint)
    assert cert.domains == ~w/mysite.com www.mysite.com/
  end
end
