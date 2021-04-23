defmodule InmanaWeb.RestaurantsControllerTest do
  use InmanaWeb.ConnCase

  describe "create/2" do
    test "when all params are valid, creates the user", %{conn: conn} do
      params = %{name: "Siri cascudo", email: "siri@cascudo.com"}

      response =
        conn
        |> post(Routes.restaurants_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "message" => "Restaurant created!",
               "restaurant" => %{
                 "id" => _id,
                 "name" => "Siri cascudo",
                 "email" => "siri@cascudo.com"
               }
             } = response
    end

    test "when there are invalid params, returns an erro", %{conn: conn} do
      params = %{email: "siri@cascudo.com"}

      expected_response = %{"message" => %{"name" => ["can't be blank"]}}

      response =
        conn
        |> post(Routes.restaurants_path(conn, :create, params))
        |> json_response(:bad_request)

      assert expected_response == response
    end
  end
end
