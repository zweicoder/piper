defmodule Piper do
  @moduledoc """
  Overrides the Kernel Pipe operator to allow specifying positions
  """

  @doc """
  This is the same as the kernel one
  """
  defmacro left ~> right do
    [{h, _} | t] = unpipe({:~>, [], [left, right]})
    :lists.foldl fn {x, pos}, acc ->
      case Macro.pipe_warning(x) do
        nil -> :ok
        message ->
          :elixir_errors.warn(__CALLER__.line, __CALLER__.file, message)
      end
      Macro.pipe(acc, x, pos)
    end, h, t
  end

  @doc """
  Breaks a pipeline expression into a list. This is where the target position being calculated.
          PipeTo.unpipe(quote do: 5 ~> div(100, _) ~> div(2))
          # => [{5, 0},
          #     {{:div, [context: Elixir, import: Kernel], 'd'}, 1},
          #     {{:div, [], [2]}, 0}]
  """
  @spec unpipe(Macro.t) :: [Macro.t]
  def unpipe(expr) do
    :lists.reverse(unpipe(expr, []))
  end

  defp unpipe({:~>, _, [left, right]}, acc) do
    unpipe(right, unpipe(left, acc))
  end

  defp unpipe(ast = {_, _, args}, acc) when is_list(args) do
    case Enum.find_index(args, &is_placeholder?/1) do
      nil ->
        [{ast, 0} | acc]
      idx ->
        {fun, meta, args} = ast
        ast = {fun, meta, List.delete_at(args, idx)}
        # format taken in by Macro.pipe/3
        [{ast, idx} | acc]
    end
  end

  defp unpipe(other, acc) do
    [{other, 0} | acc]
  end

  defp is_placeholder?({:_, _, _}),  do: true
  defp is_placeholder?(_), do: false
  
end
