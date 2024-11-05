defmodule CandleStick do
  defstruct [:date, :open, :high, :low, :close]
end

defmodule Trading do
  def process_event(_event, _strategy) do
  end

  alias NimbleCSV.RFC4180, as: CSV

  def compute_net_return(strategy: _strategy, data_source: data_source) do
    data_source
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(&parse_candlestick/1)
    |> Enum.to_list()
    |> IO.inspect()
  end

  defp parse_candlestick([date, open, high, low, close, _adj, _volume]) do
    %CandleStick{
      date: date,
      open: String.to_float(open),
      high: String.to_float(high),
      low: String.to_float(low),
      close: String.to_float(close)
    }
  end
end
