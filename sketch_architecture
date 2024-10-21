# Tactic

transforms events into orders
- handle_event(event, state_of_markets, state_of_tactic)
- knows definition of each info needed
- knows its risk unity (1 contract = some amount of risk)

# OrderState

keep track of orders
- can receive new order from tactic
- can receive cancel from tactic
- send orders to broker
- receive update from broker about an order
- notify tactic of order filled

# MarketState

keep track of historical prices (like a candlestick per day per market)
- can receive new historical prices from broker/data vendor/cache
- knows derived information about prices (highest high, atr, ...)
- can be queried about those

# TacticState

keep track of tactic positions
- can receive new position
- can be queried about positions

# Strategy

- contains strategies and tactics
- assigns risk budget to each child

# AccountState

keep track of liquidity and open contracts (and margin)

