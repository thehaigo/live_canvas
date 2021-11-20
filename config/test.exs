import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_canvas, LiveCanvasWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "yyjrPkqugXlOk6cNUuiTpi3YzPY7xI/29Q/Wo2fXSi8hU8l4xsf0qD942wasQET2",
  server: false

# In test we don't send emails.
config :live_canvas, LiveCanvas.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
