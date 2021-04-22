defmodule Inmana.Welcomer do
  # Receber um nome e uma idade do usuario
  # Se o usuario chamar "banana" e tiver "42" anos, retorna uma mensagem especial
  # Se o usuario for maior de idade, mensagem normal
  # Se o usuario for menor de idade, retorna erro
  # Tratar o nome do usuario, pra entradas erradas, como "BaNaNa", "BaNaNa        \n"
  def welcome(%{"name" => name, "age" => age}) do
    age = String.to_integer(age)

    name
    |> String.trim()
    |> String.downcase()
    |> evaluate(age)
  end

  defp evaluate("banana", 42) do
    {:ok, "You are very special banana"}
  end

  defp evaluate(name, age) when age >= 18 do
    {:ok, "Welcome #{name}"}
  end

  defp evaluate(name, _age) do
    {:error, "You shall not pass #{name}"}
  end
end
