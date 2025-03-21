defmodule Trading.Tactic.BuyHold do
  @moduledoc "Basic tactic which just buy and hold a security"

  def info, do: []

  def handle_event(%Trading.Event.DayEnded{}, %{}, _tactic_state) do
    %Trading.Positions.Market{symbol: nil, position: 1}
  end

  def risk, do: 1
end
