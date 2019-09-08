# str.bash - string functions

# blank? is true if the supplied argument is empty or consists only of
# whitespace
str.blank? () {
  [[ ${1:-} =~ ^[[:space:]]*$ ]]
}

str.capitalize () {
  echo ${1^}
}

# replace replaces all instances of the second argument with the third in the
# value of the first argument
str.replace () {
  echo ${1//$2/$3}
}
