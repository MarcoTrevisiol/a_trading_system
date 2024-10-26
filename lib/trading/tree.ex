defmodule Trading.Tree do
  @types [:bar, :point, [:point, :point], :window]

  # :bar -> :point
  # :open, :high, :low, :close

  # :point -> :point
  # :shift, :(n)*

  # :point -> :window
  # :rolling(n), :expwindow(n)

  # :window -> :point
  # :max_agg, :min_agg, :mean

  # :point_x_point -> :point, :point -> (:point -> :point)
  # :+, :-, :*, :/, :min, :max

  # :point
  # consts

  # :point -> :point_x_point
  # diagonal

  def types, do: @types

  # :input_type -> :output_type
  defstruct [:map, :input_type, :output_type]

  defstruct [:map, :type]

  # a b + c +
  # :bar -> ... -> :bar -> :point

  # diff(high(day),low(day))
  # :type = :bar -> :bar -> :point
  # (:bar->:point)(:bar->:point)(:point->:point->:point)
  # (high)(low)(diff)
end
