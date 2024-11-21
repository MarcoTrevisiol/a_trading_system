defmodule Trading.Event do
  @moduledoc """
  Containers for various types of event which can be processed
  """

  defmodule DayEnded do
    @moduledoc false
    defstruct [:datetime]
  end

  defmodule OrderFilled do
    @moduledoc false
    defstruct [:datetime, :price, :order]
  end
end
