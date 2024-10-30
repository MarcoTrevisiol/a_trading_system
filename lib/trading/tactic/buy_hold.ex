defmodule BuyHold do
  defp handle_event(
         %Trading.Event.DayEnded{datetime: _datetime},
         %{day_number: _day_number},
         _tactic_state
       ) do
    %Trading.Orders.Market{symbol: nil, quantity: 1}
  end

  def tactic do
    %Trading.Tactic{
      handle_event: fn e, ms, ts -> handle_event(e, ms, ts) end,
      info: [:day_number],
      risk: 1
    }
  end
end
