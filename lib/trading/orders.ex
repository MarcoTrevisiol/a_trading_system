defmodule Trading.Orders do
  @moduledoc "containers for various type of orders to be sent to the broker"
  defmodule Market do
    @moduledoc false
    defstruct [:symbol, :quantity]
  end

  defmodule Limit do
    @moduledoc false
    defstruct [:symbol, :quantity, :limit_price]
  end

  defmodule Stop do
    @moduledoc false
    defstruct [:symbol, :quantity, :stop_price]
  end
end
