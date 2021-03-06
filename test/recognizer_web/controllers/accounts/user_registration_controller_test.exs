defmodule RecognizerWeb.Accounts.UserRegistrationControllerTest do
  use RecognizerWeb.ConnCase

  import Recognizer.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Create Account</h2>"
      assert response =~ "Log in</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(insert(:user)) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/settings"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => params_for(:user)
        })

      assert Recognizer.Guardian.Plug.current_resource(conn)
      assert redirected_to(conn) =~ "/settings"

      # Now do a logged in request and assert on the menu
      conn
      |> get("/")
      |> html_response(200)
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Create Account</h2>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "must contain a number"
    end
  end
end
