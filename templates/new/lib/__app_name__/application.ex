defmodule <%= app_module %>.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: <%= app_module %>.Supervisor]

    children =
      [
        # {<%= app_module %>.Worker, arg},
      ] ++ children(target(), env())

    Supervisor.start_link(children, opts)
  end

  defp children(:host, _env) do
    [
      # {<%= app_module %>.Worker, arg},
    ]
  end

  defp children(_target, _env) do
    [
      # {<%= app_module %>.Worker, arg},
    ]
  end

  defp env() do
    Application.get_env(:<%= app_name %>, :env)
  end

  defp target() do
    Application.get_env(:<%= app_name %>, :target)
  end
end
