# os.bash - operating system functions

# dir? is true if the argument is a directory
os.dir? () {
  [[ -d $1 ]]
}

# file? is true if the argument is a file-like object
os.file? () {
  [[ -e $1 ]]
}

# installed? is true if the argument is a valid command
os.installed? () {
  type $1 &>/dev/null
}

# distro identifies whether we are on a mac or ubuntu
os.distro () {
  [[ $OSTYPE == darwin* ]] && {
    echo mac
    return
  }
  grep -q ubuntu /etc/os-release 2>/dev/null && echo ubuntu
}
