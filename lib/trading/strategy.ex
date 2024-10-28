defmodule Trading.Strategy do
  defstruct substrategies: []

  defmodule WeightedStrategy do
    defstruct [:substrategy, weight: 1]
  end
end
