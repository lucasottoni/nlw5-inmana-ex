defmodule Inmana.Restaurants.Get do
  alias Inmana.{Repo, Restaurant}

  def call(uuid) do
    case Repo.get(Restaurant, uuid) do
      nil -> {:error, %{result: "Restaurant not found", status: :not_found}}
      restaurant -> {:ok, restaurant}
    end
  end
end
