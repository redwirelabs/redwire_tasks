defmodule Coverage do
  @moduledoc false

  # A list of modules to ignore when code coverage runs.
  def ignore_modules do
    [
      <%= app_module %>,
      <%= app_module %>.Application,
    ]
  end
end
