# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :awesome_batteries,
  ecto_repos: [AwesomeBatteries.Repo]

# Configures the endpoint
config :awesome_batteries, AwesomeBatteriesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zodpo0VEj8eliPDxCh0d+bbGy11TQs/tlSwyooJayrzeHoC4AwA+S20le03AR8iZ",
  render_errors: [view: AwesomeBatteriesWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwesomeBatteries.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :awesome_batteries, AwesomeBatteries.Scheduler,
  jobs: [
    # Runs every midnight:
    # {"*/30 * * * *",         {AwesomeBatteries, :sync_data, []}},
    {"@daily",         {AwesomeBatteries, :sync_data, []}},
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
