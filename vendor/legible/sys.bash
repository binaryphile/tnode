# sys.bash - shell/system functions

# aliases controls whether shell aliases can be used in scripts
sys.aliases () {
  case $1 in
    on  ) shopt -s expand_aliases;;
    off ) shopt -u expand_aliases;;
  esac
}

# die exits with the last result code and prints the arguments on stdout
sys.die () {
  local -i rc=$?
  local arg

  for arg; do
    echo "$arg"
  done
  exit $rc
}

# globbing controls whether path globbing is enabled
sys.globbing () {
  case $1 in
    on  ) set +o noglob;;
    off ) set -o noglob;;
  esac
}

# rc sets the result code - error codes will cause exit in strict!
sys.rc () {
  return $1
}

# sourced? returns true if the calling file has been sourced rather than run
sys.sourced? () {
  [[ ${FUNCNAME[1]} == source ]]
}

# strict controls whether the script exits on errors and expansions of unset
# variables
sys.strict () {
  case $1 in
    on  ) set -euo pipefail;;
    off ) set +euo pipefail;;
  esac
}

# trace controls debug tracing
sys.trace () {
  case $1 in
    on  ) set -o xtrace;;
    off ) set +o xtrace;;
  esac
}

# wordSplitOnSpaceAndTab controls whether word-splitting of expansions
# happens with all whitespace or just newlines
sys.wordSplitOnSpaceAndTab () {
  case $1 in
    on  ) IFS=$' \t\n';;
    off ) IFS=$'\n'   ;;
  esac
}
