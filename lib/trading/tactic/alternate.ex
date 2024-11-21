defmodule Trading.Tactic.Alternate do
  @moduledoc "Dummy tactic which alternate long and short position every market day"

  defp handle_event(
         %Trading.Event.DayEnded{datetime: _datetime},
         %{day_number: day_number},
         _tactic_state
       ) do
    case rem(day_number, 2) do
      0 -> %Trading.Orders.Market{symbol: nil, quantity: 1}
      1 -> %Trading.Orders.Market{symbol: nil, quantity: -1}
    end
  end

  def tactic do
    %Trading.Tactic{
      handle_event: &handle_event/3,
      info: [:day_number],
      risk: 1
    }
  end
end
