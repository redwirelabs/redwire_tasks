defmodule RedwireTasks.MixProject do
  use Mix.Project

  def project do
    [
      app: :redwire_tasks,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      "docs.show": ["docs", &open("doc/index.html", &1)],
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
    ]
  end

  defp description do
    "Redwire Labs mix tasks"
  end

  defp docs do
    [
      extras: ["README.md", "LICENSE.txt"]
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/redwirelabs/redwire_tasks"},
      maintainers: ["Alex McLain"],
      files: [
        "lib",
        "mix.exs",
        "LICENSE.txt",
        "README.md",
      ]
    ]
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
