defmodule Trading.Tactic do
  @moduledoc """
  A Tactic is a basic build block for a Strategy, operating on a single security.

  It knows how to handle events to generate orders.
  It knows the info that requires to handle events.
  It knows its risk on a single unit of a security.
  """
  defstruct [:handle_event, :info, :risk]
end
