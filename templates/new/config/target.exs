import Config

config :shoehorn, init: [:nerves_runtime, :nerves_pack]

config :nerves, :erlinit, update_clock: true

config :nerves,
  erlinit: [
    hostname_pattern: "%s"
  ]

# config :nerves, :firmware, provisioning: :nerves_hub_link

# config :nerves_hub_link,
#   org: "",
#   remote_iex: true,
#   device_api_host: "",
#   device_api_sni: "",
#   fwup_public_keys: [""]

config :sentry,
    dsn: "",
    tags: %{version: Mix.Project.config()[:version]},
    included_environments: [:prod],
    enable_source_code_context: true,
    root_source_code_paths: [File.cwd!()]

config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    # {"wlan0", %{type: VintageNetWiFi}}
  ]

config :mdns_lite,
  hosts: [:hostname, "<%= app_name %>"],
  ttl: 120,
  services: [
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    }
  ]

# Configure the device for SSH IEx prompt access and firmware updates

keys =
  case System.get_env("SSH_GITHUB_USERS") do
    nil ->
      # Use a key on the local machine if it exists.

      [
        Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
        Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
        Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
      ]
      |> Enum.filter(&File.exists?/1)
      |> Enum.map(&File.read!/1)

    github_users_string ->
      # Use public SSH keys from GitHub.

      users = String.split(github_users_string)

      Enum.reduce(users, [], fn user, keys ->
        keys ++
          case System.cmd("curl", ["-s", "-f", "https://github.com/#{user}.keys"]) do
            {response, 0} ->
              response
              |> String.split("\n")
              |> Enum.filter(&(&1 != ""))

            {_, _} ->
              Mix.raise("Failed to get SSH keys from GitHub for user `#{user}`")
          end
      end)
  end

if keys == [] do
  case System.get_env("SSH_GITHUB_USERS") do
    nil ->
      Mix.raise("""
      No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
      log into the Nerves device and update firmware on it using ssh.
      See your project's config.exs for this error message.
      """)

    _github_users_string ->
      Mix.raise("""
      No github SSH public keys found from list of users in SSH_GITHUB_USERS.
      An ssh authorized key is needed to log into the Nerves device and update
      firmware on it using ssh.
      See your project's config.exs for this error message.
      """)
  end
end

config :nerves_ssh, authorized_keys: keys
