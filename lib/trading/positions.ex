defmodule Trading.Positions do
  @moduledoc "containers for various type of orders emitted by tactics"
  defmodule Market do
    @moduledoc false
    defstruct [:symbol, :position, :tactic_id]
  end

  defmodule Limit do
    @moduledoc false
    defstruct [:symbol, :position, :limit_price, :tactic_id]
  end

  defmodule Stop do
    @moduledoc false
    defstruct [:symbol, :position, :stop_price, :tactic_id]
  end
end
