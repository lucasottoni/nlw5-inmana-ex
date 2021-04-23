defmodule Inmana.RestaurantTest do
  use Inmana.DataCase

  alias Ecto.Changeset
  alias Inmana.Restaurant

  describe "changeset/1" do
    test "when all params are valid, returns a valid changeset" do
      params = %{name: "Siri cascudo", email: "siri@cascudo.com"}

      result = Restaurant.changeset(params)

      assert %Changeset{
               changes: %{
                 email: "siri@cascudo.com",
                 name: "Siri cascudo"
               },
               valid?: true
             } = result
    end

    test "when there are invalid params, returns a invalid changeset" do
      params = %{name: "S", email: ""}
      expected_result = %{email: ["can't be blank"], name: ["should be at least 2 character(s)"]}

      result = Restaurant.changeset(params)

      assert %Changeset{valid?: false} = result

      assert errors_on(result) == expected_result
    end
  end
end
