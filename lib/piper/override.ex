defmodule Piper.Override do
  import Kernel, except: [{:|>, 2}]
  import Piper

  # Need to do this again in where it's being `use`-d
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [{:|>, 2}]
      import Piper
      import unquote(__MODULE__)
    end
  end

  # Basically force redefine the `|>` macro to use `~>`
  defmacro left |> right do
    quote do
      unquote(left) ~> unquote(right)
    end
  end
end
