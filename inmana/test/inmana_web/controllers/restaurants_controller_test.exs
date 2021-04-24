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

  describe "index/2" do
    test "when there are no restaurant", %{conn: conn} do
      response =
        conn
        |> get(Routes.restaurants_path(conn, :index, page: 1, per_page: 10))
        |> json_response(:ok)

      assert %{
               "restaurants" => []
             } = response
    end

    test "when there is only one restaurant", %{conn: conn} do
      params = %{name: "Siri cascudo", email: "siri@cascudo.com"}
      {:ok, _restaurant} = Inmana.create_restaurant(params)

      response =
        conn
        |> get(Routes.restaurants_path(conn, :index, page: 1, per_page: 10))
        |> json_response(:ok)

      assert %{
               "restaurants" => [
                 %{
                   "id" => _id,
                   "name" => "Siri cascudo",
                   "email" => "siri@cascudo.com"
                 }
               ]
             } = response
    end

    test "when there are 2 restaurants", %{conn: conn} do
      params = %{name: "Siri cascudo", email: "siri@cascudo.com"}
      {:ok, _restaurant} = Inmana.create_restaurant(params)

      params = %{name: "Siri cascudo2", email: "siri@cascudo2.com"}
      {:ok, _restaurant} = Inmana.create_restaurant(params)

      response =
        conn
        |> get(Routes.restaurants_path(conn, :index, page: 1, per_page: 10))
        |> json_response(:ok)

      assert %{
               "restaurants" => [
                 %{
                   "id" => _id,
                   "name" => "Siri cascudo",
                   "email" => "siri@cascudo.com"
                 },
                 %{
                   "id" => _id2,
                   "name" => "Siri cascudo2",
                   "email" => "siri@cascudo2.com"
                 }
               ]
             } = response
    end
  end
end
