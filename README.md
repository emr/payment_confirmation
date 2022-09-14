# PaymentConfirmation

Track the status of a transaction on the Ethereum network in realtime.

## Environment

This app developed with `Elixir 1.14.0` and `Mix 1.14.0`.

## Start

  * This app needs to connect Ethereum mainnet, so you need to provide `ETH_NODE_URL` environment variable to run.
  * Also you can configure web server port via `PORT` env variable.
  * Dependencies must be installed with `mix deps.get`
  * And you can run the web server with `mix phx.server` command.

```bash
export PORT=4000
export ETH_NODE_URL="https://eth-mainnet.g.alchemy.com/v2/Ee49dY5NXWywgxJNkTNAdChuUF8zaNaD"
mix phx.server
```
(that node url above is created from Alchemy by me, it's limited, you can use it for testing purposes)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To read further information about internal modules, you can check out **moduledocs**, and **readme** files of the apps.

  * [`apps/eth/README.md`](https://github.com/emr/payment_confirmation/tree/main/apps/eth)
