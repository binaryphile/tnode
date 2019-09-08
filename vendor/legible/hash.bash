hash.keys () {
  local -n Ref=$1

  echo "${!Ref[*]}"
}
