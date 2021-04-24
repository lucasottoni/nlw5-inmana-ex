defmodule Inmana.Restaurants.List do
  alias Inmana.{Repo, Restaurant}

  def call do
    Repo.all(Restaurant)
  end
end
