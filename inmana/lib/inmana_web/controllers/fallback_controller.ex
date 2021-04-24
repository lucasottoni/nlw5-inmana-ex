defmodule InmanaWeb.FallbackController do
  use InmanaWeb, :controller

  def call(conn, {:error, %{result: result, status: status}}) do
    conn
    |> put_status(status)
    |> put_view(InmanaWeb.ErrorView)
    |> render("error.json", result: result)
  end

  def call(conn, other) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(InmanaWeb.ErrorView)
    |> render("error.json", result: other)
  end
end
