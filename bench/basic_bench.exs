defmodule BasicBench do
  use Benchfella
  import Piper

  @lst Enum.to_list(1..1000)

  bench "400 |> (&Enum.at(@lst), &1).()" do
    400 |> (&Enum.at(@lst, &1)).()
  end

  bench "400 ~> Enum.at(@lst, _)" do
    400 ~> Enum.at(@lst, _)
  end

  bench "400 |> (fn x -> Enum.at(@lst, x) end).()" do
    400 |> (fn x -> Enum.at(@lst, x) end).()
  end

  use Piper.Override
  bench "(override) 400 |> Enum.at(@lst, _)" do
    400 |> Enum.at(@lst, _)
  end
end
