# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pub_sub_demo,
  ecto_repos: [PubSubDemo.Repo]

# Configures the endpoint
config :pub_sub_demo, PubSubDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "t3ppuTo/Qv7oEIXOSGsLEWMLpfm7BPnalXCg5TcPeiLWzYncpFb159lyvwXRCrAu",
  render_errors: [view: PubSubDemoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PubSubDemo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
