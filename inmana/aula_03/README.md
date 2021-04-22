# NLW#5 - Projeto Inmana

## language: Elixir

## AULA 03 - Orbit

### Nova migration para supplies:

```sh
$ mix ecto.gen.migration create_supplies_table
```

```elixir
defmodule Inmana.Repo.Migrations.CreateSuppliesTable do
  use Ecto.Migration

  def change do
    create table(:supplies) do
      add :description, :string
      add :expiration_date, :date
      add :responsible, :string
      add :restaurant_id, references(:restaurants, type: :binary_id)

      timestamps()
    end
  end
end
```

```sh
$ mix ecto.migrate
```

### Criacao da Entidade Supplies

Criar o arquivo `lib/inmana/supply.ex`

```elixir
defmodule Inmana.Supply do
  use Ecto.Schema
  import Ecto.Changeset

  alias Inmana.Restaurant

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_params [:description, :expiration_date, :responsible, :restaurant_id]

  @derive {Jason.Encoder, only: @required_params ++ [:id]}

  schema "supplies" do
    field :description, :string
    field :expiration_date, :date
    field :responsible, :string

    belongs_to :restaurant, Restaurant

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> validate_length(:description, min: 3)
    |> validate_length(:responsible, min: 3)
  end
end
```

Alterar o arquivo `lib/inmana/restaurant.ex` para associar a lista de supplies ao restaurante

```elixir
  schema "restaurants" do
    field :email, :string
    field :name, :string

    has_many :supplies, Supply

    timestamps()
  end
```

### Criação do Service e Controller para supplies

Criar o arquivo `lib/inmana/supplies/create.ex`

```elixir
defmodule Inmana.Supplies.Create do
  alias Inmana.{Repo, Supply}

  def call(params) do
    params
    |> Supply.changeset()
    |> Repo.insert()
    |> handle_insert()
  end

  defp handle_insert({:ok, %Supply{}} = result), do: result

  defp handle_insert({:error, result}), do: {:error, %{result: result, status: :bad_request}}
end
```

Alterar o arquivo `lib/inmana/inmana.ex`

```elixir
  alias Inmana.Restaurants.Create, as: RestaurantCreate
  alias Inmana.Supplies.Create, as: SupplyCreate

  defdelegate create_restaurant(params), to: RestaurantCreate, as: :call
  defdelegate create_supply(params), to: SupplyCreate, as: :call
```

Criar o arquivo `lib/inmana_web/controllers/supplies_controller.ex`

```elixir
defmodule InmanaWeb.SuppliesController do
  use InmanaWeb, :controller

  alias Inmana.Supply

  alias InmanaWeb.FallbackController

  action_fallback FallbackController

  def create(conn, params) do
    with {:ok, %Supply{} = supply} <- Inmana.create_supply(params) do
      conn
      |> put_status(:created)
      |> render("create.json", supply: supply)
    end
  end
end
```

Criar a rota `/supplies`, alterando o arquivo `router.ex`, adicionando dentro de "scope /api":

```elixir
post "/supplies", SuppliesController, :create
```

Criar o arquivo `lib/inmana_web/views/supplies_view.ex`

```elixir
defmodule InmanaWeb.SuppliesView do
  use InmanaWeb, :view

  def render("create.json", %{supply: supply}) do
    %{
      message: "Supply created!",
      supply: supply
    }
  end
end
```

Subir o servidor e testar a rota `POST http://localhost:4000/supplies`

```
mix phx.server
```

```json
{
  "restaurant_id": "541263ca-bfe9-4d03-9c74-4bbca65df011",
  "description": "Molho de tomate",
  "expiration_date": "2021-04-22",
  "responsible": "Banana man"
}
```

### Rotas de leitura

Vamos criar a rota de listar os supplies e obter o supply pelo id

Alterar o arquivo `router.ex` substituindo a rota de post no `/supplies` pelo trecho abaixo:

[~~post "/supplies", SuppliesController, :create~~]

```elixir
resources "/supplies", SuppliesController, only: [:create, :show]
```

Criar o método show no `supplies_controller`

```elixir
  def show(conn, %{"id" => uuid}) do
    with {:ok, %Supply{} = supply} <- Inmana.get_supply(uuid) do
      conn
      |> put_status(:ok)
      |> render("show.json", supply: supply)
    end
  end
```

Já incluir os novos alias e delegates que serão criados no `inmana.ex`

```elixir
  alias Inmana.Supplies.Get, as: SupplyGet

  defdelegate get_supply(params), to: SupplyGet, as: :call
```

Criar o modulo `Supplies.Get` criando o arquivo `lib/inmana/supplies/get.ex`

```elixir
defmodule Inmana.Supplies.Get do
  alias Inmana.{Repo, Supply}

  def call(uuid) do
    case Repo.get(Supply, uuid) do
      nil -> {:error, %{result: "Supply not found", status: :not_found}}
      supply -> {:ok, supply}
    end
  end
end
```

Criar o método de renderizar o "show" no `supplies_view.ex`

```elixir
  def render("show.json", %{supply: supply}), do: %{supply: supply}
```

Ajustar o `error_view.ex` para contemplar erro:

```elixir
  def render("error.json", %{result: result}) do
    %{message: result}
  end
```

Testar através da rota GET `http://localhost:4000/api/supplies/:id`

### Obter itens vencidos

Iniciaremos criando um modulo para retornar os supplies conforme data de expiração através do arquivo `lib/inmana/supplies/get_by_expiration.ex`

```elixir
defmodule Inmana.Supplies.GetByExpiration do
  import Ecto.Query

  alias Inmana.{Repo, Restaurant, Supply}

  def call do
    today = Date.utc_today()

    beginning_of_week = Date.beginning_of_week(today)
    end_of_week = Date.end_of_week(today)

    query =
      from supply in Inmana.Supply,
        where:
          supply.expiration_date >= ^beginning_of_week and supply.expiration_date <= ^end_of_week,
        preload: [:restaurant]

    query
    |> Repo.all()
    |> Enum.group_by(fn %Supply{restaurant: %Restaurant{email: email}} -> email end)
  end
end

```

### Setup para Envio de email

Incluir a dependencia da lib bamboo para envio de email no arquivo `mix.exs`

```elixir
{:bamboo, "~> 2.1.0"}
```

Incluir o config para o adapter do bamboo rodar localmente, no arquivo `config/config.exs`

```elixir
config :inmana, Inmana.Mailer, adapter: Bamboo.LocalAdapter
```

Criar o modulo `Inmana.Mailer` através do arquivo `lib/inmana/mailer.ex`

```elixir
defmodule Inmana.Mailer do
  use Bamboo.Mailer, otp_app: :inmana
end
```

Incluir uma config para visualiza localmente os emails enviados no ambiente de desenvolvimento, alterando o arquivo `lib/inmana_web/router.ex`

```elixir
  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
```

### Notificar as expirações

Criar um modulo para montar o email a partir de uma lista de supplies, no arquivo `lib/inmana/supplies/expiration_email.ex`

```elixir
defmodule Inmana.Supplies.ExpirationEmail do
  import Bamboo.Email

  alias Inmana.Supply

  def create(to_email, supplies) do
    new_email(
      to: to_email,
      from: "app@inmana.com.br",
      subject: "Supplies that are about to expire",
      text_body: email_text(supplies)
    )
  end

  defp email_text(supplies) do
    initial_text = "--------- Supplies that are about to expire: ----------\n"

    Enum.reduce(supplies, initial_text, fn supply, text -> text <> supply_string(supply) end)
  end

  defp supply_string(%Supply{
         description: description,
         expiration_date: expiration_date,
         responsible: responsible
       }) do
    "Description: #{description}, Expiration date: #{expiration_date}, Responsible: #{responsible}\n"
  end
end
```

Criar um modulo para envio das expirações em `lib/inmana/supplies/expiration_notification.ex`

```elixir
defmodule Inmana.Supplies.ExpirationNotification do
  alias Inmana.Mailer
  alias Inmana.Supplies.{ExpirationEmail, GetByExpiration}

  def send do
    data = GetByExpiration.call()

    Enum.each(data, fn {to_email, supplies} ->
      to_email
      |> ExpirationEmail.create(supplies)
      |> Mailer.deliver_later!()
    end)
  end
end
```

Iniciar o servidor junto com o iex e invocar o envio de email dos suprimentos expirados

```
iex -S mix phx.server

iex> Inmana.Supplies.ExpirationNotification.send()
```

Acessar no browser a url `http://localhost:4000/sent_emails` para visualizar os emails enviados.
