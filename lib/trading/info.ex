defmodule Info do
  def build_info(:day_number, _info_source) do
    fn day -> Date.day_of_era(day) |> elem(0) end
  end
end
