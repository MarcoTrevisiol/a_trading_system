defmodule Trading.Event do
  defmodule DayEnded do
    defstruct [:datetime]
  end

  defmodule OrderFilled do
    defstruct [:datetime, :price, :order]
  end
end
