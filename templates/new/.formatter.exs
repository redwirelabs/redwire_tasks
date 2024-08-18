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

# ---------------------------------------------------------------------------- #
# To enable the formatter, remove the code above and uncomment the code below.
# ---------------------------------------------------------------------------- #

# [
#   inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
# ]
