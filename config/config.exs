# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :payment_confirmation_web,
  generators: [context_app: :payment_confirmation]

# Configures the endpoint
config :payment_confirmation_web, PaymentConfirmationWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PaymentConfirmationWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PaymentConfirmation.PubSub,
  live_view: [signing_salt: "O/15Ziv9"]

config :payment_confirmation,
  env: config_env()

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/payment_confirmation_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Ethereumex
config :ethereumex,
  http_headers: [{"Content-Type", "application/json"}]

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
