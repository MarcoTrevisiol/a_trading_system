defmodule Trading.Info.DayNumber do
  @moduledoc "info for incremental day number"
  def initial_value, do: 0
  def updated_value(value, %CandleStick{}), do: value + 1
end
