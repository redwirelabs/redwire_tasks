import Config

# Configuration files are applied in the following order:
#
# 1. config/config.exs
# 2. config/target.exs
# 3. config/target/<platform>.exs
# 4. config/env/<environment>.exs

Application.start(:nerves_bootstrap)

config :<%= app_name %>,
  target: Mix.target(),
  env: Mix.env()

config :logger, backends: [RingLogger]

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "<%= source_date_epoch %>"

config :elixir, time_zone_database: Zoneinfo.TimeZoneDatabase

if Mix.target() != :host,
  do: import_config "target.exs"

import_config "target/#{Mix.target()}.exs"
import_config "env/#{Mix.env()}.exs"
