defmodule HelloWorldWeb.API.MessageControllerTest do
  use HelloWorldWeb.ConnCase, async: true

  describe "GET /api/messages/public" do
    test "should return successful response", %{conn: conn} do
      conn = get(conn, Routes.api_message_path(conn, :public))

      assert %{"message" => "The API doesn't require an access token to share this message."} =
               json_response(conn, 200)
    end
  end

  describe "GET /api/messages/protected" do
    test "should return successful response", %{conn: conn} do
      conn = get(conn, Routes.api_message_path(conn, :protected))

      assert %{"message" => "The API successfully validated your access token."} =
               json_response(conn, 200)
    end
  end

  describe "GET /api/messages/admin" do
    test "should return successful response", %{conn: conn} do
      conn = get(conn, Routes.api_message_path(conn, :admin))

      assert %{"message" => "The API successfully recognized you as an admin."} =
               json_response(conn, 200)
    end
  end

  describe "GET /api/messages/invalid" do
    test "should return 404 response code", %{conn: conn} do
      response =
        assert_error_sent 404, fn ->
          get(build_conn(), "/api/messages/invalid")
        end

      assert {404, [_h | _t], "{\"message\":\"Not found.\"}"} = response
    end
  end
end
