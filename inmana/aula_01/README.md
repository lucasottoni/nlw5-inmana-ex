# NLW#5 - Projeto Inmana

## language: Elixir

## AULA 01 - Liftoff

### Configurações de ambiente

https://www.notion.so/Configura-es-do-ambiente-9d73d4eefa7043f593d9c768922306ca

### Criar um projeto em phenix sem html e webpack (css):

```
$ mix phx.new nome_projeto --no-html --no-webpack
```

### Criar um banco de dados (postgres tem que está instalado):

```
$ mix ecto.create
```

### Executar o servidor phenix (por padrão na porta 4000):

```
$ mix phx.server
```

### Acrescentar o analisador sintático de código (o famoso linter) junto com os defaults (dentro do "defp deps do..."):

Fonte: https://github.com/rrrene/credo

Dentro do arquivo "mix.exs"

```
defp deps do
  [
    {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
  ]
end
```

### Baixar as dependências:

```
$ mix deps.get
```

### Gera um arquivo de configuração do credo (.credo.exs):

```
$ mix credo.gen.config
```

### Verifica se tem algum problema com o linter do projeto:

```
$ mix credo
```

### Verifica se tem algum problema com o linter do projeto (mais severo):

```
$ mix credo --strict
```

### Com elixirLS configurado, configurar o ">Open Settings (JSON)" no VSCode para autoformatação:

```
"editor.formatOnSave": true
```

### Outra opção de formatação com cli:

```
$ mix format
```

### Abrir o terminal no caminho da pasta do projeto e executar o iex:

```
$ iex -S mix
```

### Help (h) sobre a função do iex. no caso utilizando "String"

```
iex> h String.upcase
```

### Recompilar o código devido à modificação.

```
iex> recompile
```

## Observações:

### Utilizando alias em módulo.

"alias Inmana.Welcomer"
Após alias, utiliza somente "Welcomer" (depois as funções "Welcomer.welcome()").

### defp (função)

É uma função privada. Somente o próprio módulo tem acesso.

### Dentro da pasta "lib":

- Pasta inmana:

  - Arquivo welcomer.ex = Interação com usuário.

- Pasta inmana_web:

  - Arquivo router.ex = Arquivo de rota (
    get "/", WelcomeController, :index).

- Pasta controllers:
  - Arquivo welcome_controller.ex = Tratativa da rota get "/", WelcomeController, :index. Utilizando o módulo Inmana.Welcomer.
