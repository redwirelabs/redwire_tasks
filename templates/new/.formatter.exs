IO.puts IO.ANSI.format([
  :yellow, :bright,
  "-- The formatter is disabled --\n",
  :reset,
  """
  This repository uses a style guide.

  See:
    https://github.com/amclain/styleguides/blob/master/elixir/STYLEGUIDE.md
  """
])

exit :normal
