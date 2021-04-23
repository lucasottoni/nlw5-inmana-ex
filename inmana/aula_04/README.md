# NLW#5 - Projeto Inmana

## language: Elixir

## AULA 04 - Landing

### Tasks:

Nesta aula aprendemos sobre tasks, processamentos assíncronos em paralelo e concorrentes.

### Envio de email

Mudar o envio de email para um processamento assíncrono concorrente.
Alterar o arquivo `lib/inmana/supplies/expiration_notification.ex`

```elixir
defmodule Inmana.Supplies.ExpirationNotification do
  alias Inmana.Mailer
  alias Inmana.Supplies.{ExpirationEmail, GetByExpiration}

  def send do
    data = GetByExpiration.call()

    data
    |> Task.async_stream(fn {to_email, supplies} -> send_email(to_email, supplies) end)
    |> Stream.run()
  end

  defp send_email(to_email, supplies) do
    to_email
    |> ExpirationEmail.create(supplies)
    |> Mailer.deliver_later!()
  end
end
```

### Scheduler

Agendar o envio de email de forma automatica
Criar o arquivo `lib/inmana/supplies/scheduler.ex` que irá gerar os envios de e-mail a cada 10 segundos

```elixir
defmodule Inmana.Supplies.Scheduler do
  use GenServer

  alias Inmana.Supplies.ExpirationNotification

  # client
  def start_link(_state) do
    GenServer.start_link(__MODULE__, %{})
  end

  # server
  @impl true
  def init(state \\ %{}) do
    schedule_notification()
    {:ok, state}
  end

  @impl true
  def handle_info(:generate, state) do
    ExpirationNotification.send()

    schedule_notification()

    {:noreply, state}
  end

  # async
  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  # sync
  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  defp schedule_notification do
    Process.send_after(self(), :generate, 1000 * 10)
  end
end
```

Incluir o GenServer para iniciar junto com a aplicação. Para isto, altere o arquivo `lib/inmana/application.ex`, incluindo na função start mais um elemento no array children:

```elixir
  children = [
      Inmana.Repo,
      InmanaWeb.Telemetry,
      {Phoenix.PubSub, name: Inmana.PubSub},
      InmanaWeb.Endpoint,
      Inmana.Supplies.Scheduler
    ]
```
