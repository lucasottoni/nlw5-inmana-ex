defmodule Inmana do
  @moduledoc """
  Inmana keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Inmana.Restaurants.Create, as: RestaurantCreate
  alias Inmana.Restaurants.Get, as: RestaurantGet
  alias Inmana.Restaurants.List, as: RestaurantList

  alias Inmana.Supplies.Create, as: SupplyCreate
  alias Inmana.Supplies.Get, as: SupplyGet

  defdelegate create_restaurant(params), to: RestaurantCreate, as: :call
  defdelegate list_restaurant(), to: RestaurantList, as: :call
  defdelegate get_restaurant(params), to: RestaurantGet, as: :call

  defdelegate create_supply(params), to: SupplyCreate, as: :call
  defdelegate get_supply(params), to: SupplyGet, as: :call
end
