defmodule Trading.Tactic.Alternate do
  @moduledoc "Dummy tactic which alternate long and short position every market day"

  def info, do: [:day_number]

  def handle_event(%Trading.Event.DayEnded{}, %{day_number: day_number}, _tactic_state) do
    case rem(day_number, 2) do
      0 -> [%Trading.Positions.Market{symbol: nil, position: +1}]
      1 -> [%Trading.Positions.Market{symbol: nil, position: -1}]
    end
  end

  def risk, do: 1
end
