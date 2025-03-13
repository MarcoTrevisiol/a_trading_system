defmodule Trading.AccountState do
  @moduledoc false

  def initial_state, do: %{usd: 0}

  # defstruct [:security_name, :quantity]
  def update(account_state, filled_orders) do
    filled_orders
    |> Enum.reduce(account_state, &future_update/2)
  end

  defp future_update(
         %{filled_at: price, quantity: quantity},
         %{usd: usd} = account_state
       ) do
    old_quantity = Map.get(account_state, :quantity, 0)
    last_price = Map.get(account_state, :last_price, 0)
    new_quantity = old_quantity + quantity
    cash_flow = (price - last_price) * old_quantity
    %{quantity: new_quantity, last_price: price, usd: usd + cash_flow}
  end
end
