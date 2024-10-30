defmodule Trading.Orders do
  defmodule Market do
    defstruct [:symbol, :quantity]
  end

  defmodule Limit do
    defstruct [:symbol, :quantity, :limit_price]
  end

  defmodule Stop do
    defstruct [:symbol, :quantity, :stop_price]
  end
end
