Code.require_file("coverage.ignore.exs")

defmodule <%= app_module %>.MixProject do
  use Mix.Project

  @app :<%= app_name %>
  @version "0.1.0"
  @all_targets [:<%= target_name %>]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.15",
      archives: [nerves_bootstrap: "~> 1.12"],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      releases: [{@app, release()}],
      test_coverage: [tool: Coverex.Task, ignore_modules: Coverage.ignore_modules()],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore.exs",
        list_unused_filters: true,
        # plt_add_apps: [:mix],
        plt_file: {:no_warn, plt_file_path()},
      ],
      preferred_cli_env: [
        "coverage.show": :test,
        espec: :test,
      ],
      preferred_cli_target: [
        dialyzer: :<%= target_name %>,
        run: :host,
        test: :host,
      ],
    ]
  end

  def application do
    [
      mod: {<%= app_module %>.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp aliases do
    [
      "coverage.show": ["test", &open("cover/modules.html", &1)],
      "docs.show": ["docs", &open("doc/index.html", &1)],
      test: "espec --cover",
    ]
  end

  defp deps do
    [
      # Dependencies for all targets
      # {:cubdb, "~> 2.0"},
      {:coverex, "~> 1.5", only: :test},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:emqtt, "~> 1.2"},
      {:espec, "~> 1.9", only: :test},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      # {:input_event, "~> 1.2"},
      {:muontrap, "~> 1.1"},
      {:nerves, "~> 1.10", runtime: false},
      {:resolve, "~> 0.1"},
      {:ring_logger, "~> 0.11"},
      {:shoehorn, "~> 0.9"},
      {:speck, "~> 0.2"},
      {:toolshed, "~> 0.3"},
      {:x509, "~> 0.8"},
      {:zoneinfo, "~> 0.1"},

      # Dependencies for all targets except :host
      # {:circuits_gpio, "~> 1.1", targets: @all_targets},
      # {:circuits_i2c, "~> 2.0", targets: @all_targets},
      # {:circuits_spi, "~> 2.0", targets: @all_targets},
      # {:circuits_uart, "~> 1.5", targets: @all_targets},
      {:mdns_lite, "~> 0.8", targets: @all_targets},
      # {:nerves_hub_link, "~> 2.0", targets: @all_targets},
      {:nerves_key, "~> 1.2", targets: @all_targets},
      {:nerves_motd, "~> 0.1", targets: @all_targets},
      {:nerves_runtime, "~> 0.13", targets: @all_targets},
      {:nerves_ssh, "~> 0.4", targets: @all_targets},
      {:nerves_time, "~> 0.4", targets: @all_targets},
      {:sentry, "~> 8.0", targets: @all_targets},
      {:vintage_net, "~> 0.13", targets: @all_targets},
      {:vintage_net_ethernet, "~> 0.11", targets: @all_targets},
      # {:vintage_net_mobile, "~> 0.11", targets: @all_targets},
      # {:vintage_net_qmi, "~> 0.3", targets: @all_targets},
      # {:vintage_net_wifi, "~> 0.11", targets: @all_targets},
      # {:vintage_net_wireguard, "~> 0.1", targets: @all_targets},

      # Dependencies for specific targets
      nerves_system(),
    ]
  end

  defp nerves_system do
    path = System.get_env("NERVES_SYSTEM_PATH", "")

    case File.exists?(path) do
      true ->
        {
          :<%= nerves_system %>,
          path: path,
          runtime: false,
          targets: :<%= target_name %>
        }

      _ ->
        {
          :<%= nerves_system %>,
          ref: "",
          github: "redwirelabs/<%= nerves_system %>",
          runtime: false,
          targets: :<%= target_name %>
        }
    end
  end

  defp docs do
    [
      main: "readme",
      extras: ["../README.md"]
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end

  defp plt_file_path do
    [Mix.Project.build_path(), "plt", "dialyxir.plt"]
    |> Path.join()
    |> Path.expand()
  end

  # Open a file with the default application for its type.
  defp open(file, _args) do
    open_command =
      System.find_executable("xdg-open") # Linux
      || System.find_executable("open")  # Mac
      || raise "Could not find executable 'open' or 'xdg-open'"

    System.cmd(open_command, [file])
  end
end
