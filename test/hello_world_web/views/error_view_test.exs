defmodule HelloWorldWeb.ErrorViewTest do
  use HelloWorldWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(HelloWorldWeb.ErrorView, "404.json", []) == %{
             message: "Not found."
           }
  end

  test "renders 500.json" do
    assert render(HelloWorldWeb.ErrorView, "500.json", []) ==
             %{message: "Internal Server Error"}
  end
end
