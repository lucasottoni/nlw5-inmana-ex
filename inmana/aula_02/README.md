# NLW#5 - Projeto Inmana

## language: Elixir

## AULA 02 - Maximum Speed

### Criando um migration (serve para manipular as tabelas do banco de dados):

```
$ mix ecto.gen.migration nome_migration
```

### Editando o arquivo criado (migration)

Pasta priv > migrations > nome_migration.exs

```elixir
defmodule Inmana.Repo.Migrations.CreateRestaurantsTable do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :email, :string
      add :name, :string

      timestamps()
    end

    create unique_index(:restaurants, [:email])
  end
end
```

### Adicionando uuid v4

Pasta config > config.exs

```elixir
config :inmana, Inmana.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]
```

### Executar a migração.

    $ mix ecto.migrate

### Cria a lógica para incluir os dados na tabela (Schema, changeset):

Pasta lib > inmana > restautant.ex

```elixir
defmodule Inmana.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "restaurants" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:email, :name])
    |> validate_required([:email, :name])
    |> validate_length(:name, min: 2)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:email])
  end
end
```

### Pesquisa sobre validate no Ecto:

Via cli:

```
h Repo.insert
```

via site: https://hexdocs.pm/ecto/Ecto.Changeset.html

### Entendo o processo de inserir no banco:

Recebe o parâmetro |> Faz o cast através do changeset |> Passa para o Repo.insert

```sh
iex> %{name: "Lucas", email: "lucas@ottoni.com"} |> Restaurant.changeset() |> Repo.insert()
```

### Criar uma pasta para separar o arquivo por um contexto:

Pasta lib > inmana > restaurants > create.ex
Criação de um restaurante através de um módulo.

```elixir
defmodule Inmana.Restaurants.Create do
  alias Inmana.{Repo, Restaurant}

  def call(params) do
    params
    |> Restaurant.changeset()
    |> Repo.insert()
    |> handle_insert()
  end

  defp handle_insert({:ok, %Restaurant{}} = result), do: result
  defp handle_insert({:error, result}), do: {:error, %{result: result, status: :bad_request}}
end
```

### Criação de um restaurante via web (via "controller" e via uma chamada http):

Pasta > lib > inmana_web > controllers > restaurants_controller.ex

```elixir
defmodule InmanaWeb.RestaurantsController do
  use InmanaWeb, :controller

  alias Inmana.Restaurant
  alias Inmana.Restaurants.Create

  def create(conn, params) do
    with {:ok, %Restaurant{} = restaurant} <- Create.call(params) do
      conn
      |> put_status(:created)
      |> render("create.json", restaurant: restaurant)
    end
  end
end
```

### Criando um arquivo view (o que vai ser apresentado para usuário através da requisição):

Pasta lib > inmana_web > views > restaurants_view.ex

```elixir
defmodule InmanaWeb.RestaurantsView do
  use InmanaWeb, :view

  def render("create.json", %{restaurant: restaurant}) do
    %{
      message: "Restaurant Created!",
      restaurant: restaurant
    }
  end
end
```

### Alterando o arquivo restaurant.ex para ter uma leitura em Json:

```elixir
defmodule Inmana.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_params [:email, :name]

  @derive {Jason.Encoder, only: @required_params ++ [:id]}

  schema "restaurants" do
    field :email, :string
    field :name, :string

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> validate_length(:name, min: 2)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:email])
  end
end
```

### Definir a rota para Post:

Arquivo router.ex

```elixir
scope "/api", InmanaWeb do
    pipe_through :api

    get "/", WelcomeController, :index

    post "/restaurants", RestaurantsController, :create
```

### Tratativa de erros (action_fallback) amigáveis para usuário:

Arquivo restaurants_controller.ex

```elixir
defmodule InmanaWeb.RestaurantsController do
  use InmanaWeb, :controller

  alias Inmana.Restaurant
  alias Inmana.Restaurants.Create

  alias InmanaWeb.FallbackController

  action_fallback FallbackController

  def create(conn, params) do
    with {:ok, %Restaurant{} = restaurant} <- Create.call(params) do
      conn
      |> put_status(:created)
      |> render("create.json", restaurant: restaurant)
    end
  end
end
```

Criando arquivo fallback_controller.ex

```elixir
defmodule InmanaWeb.FallbackController do
  use InmanaWeb, :controller

  alias InmanaWeb.ErrorView

  def call(conn, {:error, %{result: result, status: status}}) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render("error.json", result: result)
  end
end
```

Modificar o arquivo error_view.ex

```elixir
defmodule InmanaWeb.ErrorView do
  use InmanaWeb, :view

  alias Ecto.Changeset

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("error.json", %{result: %Changeset{} = changeset}) do
    %{message: translate_erros(changeset)}
  end

  defp translate_erros(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
```

### Refatorando o código usando inmana.ex:

Editando inmana.ex

```elixir
defmodule Inmana do
  alias Inmana.Restaurants.Create

  defdelegate create_restaurant(params), to: Create, as: :call
end
```

Editando restaurants_controller.ex

```elixir
defmodule InmanaWeb.RestaurantsController do
  use InmanaWeb, :controller

  alias Inmana.Restaurant
  alias InmanaWeb.FallbackController

  action_fallback FallbackController

  def create(conn, params) do
    with {:ok, %Restaurant{} = restaurant} <- Inmana.create_restaurant(params) do
      conn
      |> put_status(:created)
      |> render("create.json", restaurant: restaurant)
    end
  end
end
```

### Ao finalizar realizar o teste novamente no "Client REST (Postman, Insomnia, etc)"

POST

```
http://localhost:4000/api/restaurants

```

```json
{
  "name": "Siri cascudo",
  "email": "siri.cascudo@fenda.com.br"
}
```
