import Config

# Default Path to Mnesia for local development
config :mnesia,
  dir: '.mnesia/#{Mix.env}/#{node()}'
