defmodule Trading.Info.Close do
  @moduledoc "info for last close price of a security"
  def initial_value, do: nil
  def updated_value(_value, %CandleStick{close: close}), do: close
end
