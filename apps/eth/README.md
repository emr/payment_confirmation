# Eth

## Eth.Network

`Eth.Network` is the module that interacts with Ethereum node using [Ethereumex](https://github.com/exthereum/ethereumex) library.

## Eth.Confirmation.Tracker

`Eth.Confirmation.Tracker` module is a GenServer that runs asynchronously. It tracks whether the given transactions are confirmed on the network. Takes the transaction hash with `Eth.Confirmation.Tracker.add/1` and sends `{:tx_confirmed, hash}` or `{:tx_failed, hash}` message to the client process when the pending transactions is confirmed or reaches maximum attempts. Uses `Eth.Confirmation.Job` to track about confirmation active jobs.

## Config

This module can be configured with the following keys in `config.exs`.

```elixir
# Configure Eth module
config :eth,
  # rpc client that implements Ethereumex.Client.Behaviour to interact with Ethereum node
  rpc_client: Ethereumex.HttpClient,
  # the time it takes when pretending to send a transaction to the network
  send_simulation_duration: 2_000,
  # frequency of checking if pending transactions have received sufficient block confirmations
  confirmation_interval: 6_000,
  # required block counts to flag a transaction as confirmed
  confirmation_block_count: 2,
  # defines after how many attempts the transaction will fail
  # that value means confirmation will fail after timeout (confirmation_max_attempts * confirmation_interval) in milliseconds
  # ex: 30 * 6_000 = 180_000 (3 mins)
  confirmation_max_attempts: 30
```
