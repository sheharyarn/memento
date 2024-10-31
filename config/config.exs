import Config

# Default Path to Mnesia for local development
config :mnesia,
  dir: ~c".mnesia/#{Mix.env()}/#{node()}"
