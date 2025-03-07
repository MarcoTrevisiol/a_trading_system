defmodule ATradingSystemWeb.ErrorJSONTest do
  use Support.ConnCase, async: true

  test "renders 404" do
    assert ATradingSystemWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert ATradingSystemWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
