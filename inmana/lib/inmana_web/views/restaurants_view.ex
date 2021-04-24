defmodule InmanaWeb.RestaurantsView do
  use InmanaWeb, :view

  def render("create.json", %{restaurant: restaurant}) do
    %{
      message: "Restaurant created!",
      restaurant: restaurant
    }
  end

  def render("index.json", %{restaurants: restaurants}) do
    %{
      restaurants: restaurants
    }
  end

  def render("show.json", %{restaurant: restaurant}) do
    %{
      restaurant: restaurant
    }
  end
end
