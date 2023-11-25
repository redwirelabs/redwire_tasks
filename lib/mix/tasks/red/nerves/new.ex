defmodule Mix.Tasks.Red.Nerves.New do
  @shortdoc "Creates a new Redwire Labs style Nerves project"

  @moduledoc """
  Creates a new Redwire Labs style Nerves project.

      mix red.nerves.new --target=TARGET [opts] PATH

  ## Examples

      mix red.nerves.new --target=am62 my_firmware

  Use an official Nerves system hosted by the Nerves Project

      mix red.nerves.new --target=bbb --org=nerves-project my_firmware

  Pin the Nerves system to a specific GitHub ref or version

      mix red.nerves.new --target=bbb --ref=v2.19.1 --org=nerves-project my_firmware

  Use a shorter alias for the target name

      mix red.nerves.new --target=sam --system=nerves_system_sama5d27_wlsom1_ek my_firmware

  Name the project's Elixir application or module different than its path

      mix red.nerves.new --target=am62 --app=my_app --module=MyApp my_firmware

  """

  use Mix.Task

  @template_dir "templates/new"

  @impl Mix.Task
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: [
      app: :string,
      module: :string,
      org: :string,
      ref: :string,
      system: :string,
      target: :string,
    ])

    required_opts = [:target]

    if length(argv) < 1,
      do: Mix.raise "Missing project path"

    Enum.each(required_opts, fn opt ->
      if is_nil(opts[opt]),
        do: Mix.raise "Missing #{opt}"
    end)

    target_dir = Enum.at(argv, 0)

    if File.exists?(target_dir) &&
      not Mix.shell.yes?("Directory exists. Continue?", default: :no),
        do: Mix.raise "Aborted"

    app_name =
      case opts[:app] do
        nil ->
          target_dir
          |> Path.basename
          |> String.downcase
          |> String.replace("-", "_")

        app_name ->
          app_name
      end

    app_module =
      case opts[:module] do
        nil ->
          app_name
          |> String.split("_")
          |> Enum.map(&String.capitalize/1)
          |> Enum.join

        module_name ->
          module_name
      end

    bindings = [
      app_name: app_name,
      app_module: app_module,
      github_org: opts[:org] || "redwirelabs",
      github_ref: opts[:ref] || "main",
      nerves_system: opts[:system] || "nerves_system_#{opts[:target]}",
      target_name: opts[:target],
      source_date_epoch: DateTime.to_unix(DateTime.utc_now),
    ]

    Mix.shell.info IO.ANSI.format([
      "\n", :green,
      "Created new Nerves project at\n\n",
      "   #{target_dir}\n",
      :reset, "\n",
      "Get the project dependencies for all targets with\n\n",
      "   mix deps.targets.get\n",
    ])

    File.mkdir_p(target_dir)

    Path.wildcard(@template_dir <> "/**", match_dot: true)
    |> Enum.each(&generate_file(&1, target_dir, bindings))
  end

  defp generate_file(source_path, target_dir, bindings) do
    target_path = Path.join(target_dir, Path.relative_to(source_path, @template_dir))

    case File.dir?(source_path) do
      true ->
        target_path
        |> replace_bindings(bindings)
        |> File.mkdir_p

      _ ->
        contents = EEx.eval_file(source_path, bindings)

        target_path
        |> replace_bindings(bindings)
        |> File.write!(contents)
    end
  end

  defp replace_bindings(path, bindings) do
    Enum.reduce(bindings, path, fn {key, value}, acc ->
      String.replace(acc, "__#{key}__", to_string(value))
    end)
  end
end
