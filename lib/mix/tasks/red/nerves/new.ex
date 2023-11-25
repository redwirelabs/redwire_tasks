defmodule Mix.Tasks.Red.Nerves.New do
  @shortdoc "Creates a new Redwire Labs style Nerves project"
  @moduledoc """
  Creates a new Redwire Labs style Nerves project.
  """

  use Mix.Task

  @template_dir "templates/new"
  @target_dir "/tmp/project"

  @impl Mix.Task
  def run(_args) do
    File.rm_rf(@target_dir) # TODO: REMOVE #####################################
    File.mkdir_p(@target_dir)

    bindings = [
      app_name: "foo",
      app_module: "Foo",
      nerves_system: "nerves_system_bbb",
      target_name: "bbb",
      source_date_epoch: DateTime.to_unix(DateTime.utc_now)
    ]

    Path.wildcard(@template_dir <> "/**", match_dot: true)
    |> Enum.each(&generate_file(&1, bindings))
  end

  defp generate_file(source_path, bindings) do
    target_path = Path.join(@target_dir, Path.relative_to(source_path, @template_dir))

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
