import Config

config :logger, backends: [RingLogger, Sentry.LoggerBackend]

config :logger, :<%= app_name %>, level: :debug

config :logger, Sentry.LoggerBackend,
  capture_log_messages: true,
  level: :error,
  utc_log: true

config :sentry, environment_name: :prod

config :mdns_lite, services: []

# if Mix.target() != :host do
#   config :nerves_hub_link,
#     device_api_host: "",
#     device_api_sni: "",
#     fwup_public_keys: [""]
# end
