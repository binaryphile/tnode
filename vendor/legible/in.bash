# in.bash - read from stdin

alias in.readlns=cat

# readHeredoc reads either a heredoc or until EOF from stdin.  It removes
# indentation from all lines of the heredoc based on the indentation of the
# first line.
in.readHeredoc () {
  local indent input nl

  nl=$'\n'
  input=$(in.readlns)
  indent=${input%%[^[:space:]]*}
  input=${input#$indent}
  echo "${input//$nl$indent/$nl}"
}

# readKeySilent reads a key from stdin without local echo
in.readKeySilent () {
  local input

  read -sn 1 input
  echo $input
}
