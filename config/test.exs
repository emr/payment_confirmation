import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :payment_confirmation_web, PaymentConfirmationWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "z+7/X6nqSsFukmau4pO+Ml/UdTU495oa4Cr9+4GfENVtmT10J+JUypTuR78jBbs+",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
