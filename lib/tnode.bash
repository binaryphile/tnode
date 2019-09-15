set -o noglob

# A node is referred to by its node id and the two terms are used
# interchangeably here.

# Tnode_next is the id of the next unallocated self
declare -i Tnode_next=1

# NL is newline
NL=$'\n'

# I is an integer result
declare -i I

# left returns the left of the given node.
tnode.left () {
  local -n left=Tnode_left$1

  S=$left
  Tnode.interactive? && echo "$S";:
}

# name returns the name of the given node.
tnode.name () {
  local -n name=Tnode_name$1

  S=$name
  Tnode.interactive? && echo "$S";:
}

# new allocates a new node.  If a value is supplied, it becomes the value of
# the new node.
tnode.new () {
  local name=${1:-}
  local self

  self=$Tnode_next
  Tnode_next+=1

  declare -g Tnode_name$self=$name
  declare -g Tnode_parent$self=0
  declare -Ag Tnode_children$self="()"
  declare -ig Tnode_left$self=0
  declare -ig Tnode_right$self=0

  S=$self
  Tnode.interactive? && echo "$S";:
}

tnode.number () {
  local self=$1
  local -i i=$2
  local -n children=Tnode_children$self
  local child

  tnode.setLeft $self $i
  i+=1

  for child in ${!children[*]}; do
    tnode.number $child $i
    i=$I
  done

  tnode.setRight $self $i
  I=i+1
}

# parent returns the parent of the given self.
tnode.parent () {
  local -n parent=Tnode_parent$1

  S=$parent
  Tnode.interactive? && echo "$S";:
}

# remove removes a node and all of its children
tnode.remove () {
  local self=$1
  local -n children=Tnode_children$self parent=Tnode_parent$self
  local child

  for child in ${!children[*]}; do
    tnode.remove $child
  done

  (( parent )) && unset -v Tnode_children$parent[$self]

  unset -v Tnode_children$self
  unset -v Tnode_parent$self
  unset -v Tnode_left$self
  unset -v Tnode_right$self
  unset -v Tnode_name$self
}

# right returns the right of the given self.
tnode.right () {
  local -n right=Tnode_right$1

  S=$right
  Tnode.interactive? && echo "$S";:
}

# setParent sets the parent of the given self to the self in the second
# argument.
tnode.setParent () {
  local self=$1 newParent=$2
  local -n parent=Tnode_parent$self

  (( newParent )) || return

  # bail if nothing to do
  (( newParent == parent )) && return

  parent=$newParent
  printf -v Tnode_children$newParent[$self] %s ''
}

# setLeft sets the left of the given node to the second argument.
tnode.setLeft () {
  printf -v Tnode_left$1 %s $2
}

# setName sets the name of the given node to the second argument.
tnode.setName () {
  printf -v Tnode_name$1 %s $2
}

# setRight sets the right of the given node to the second argument.
tnode.setRight () {
  printf -v Tnode_right$1 %s $2
}

tnode.toJson () {
  local self=$1
  local format left name right

  ! read -rd '' format <<'END'
{
  "name": "%s",
  "left": %s,
  "right": %s,
  "children": [%s]
}
END

  tnode.name $self
  name=$S

  tnode.left $self
  left=$S

  tnode.right $self
  right=$S

  Tnode.children $self

  Tnode.indent "$S"
  printf -v S "$format" $name $left $right "$S"
  Tnode.interactive? && echo "$S";:
}

# walk returns the nodes of the subtree including the start node.
tnode.walk () {
  local self=$1
  local -n children=Tnode_children$self
  local child results=()

  for child in ${!children[*]}; do
    tnode.walk $child
    results+=( ${A[*]} )
  done
  A=( $self ${results[*]} )
  Tnode.interactive? && echo ${A[*]};:
}

Tnode.children () {
  local -n children=Tnode_children$1
  local child results=()

  for child in ${!children[*]}; do
    tnode.toJson $child
    results+=( "$S" )
  done

  printf -v S "%s,$NL" "${results[@]}"
  S=${S%,$NL}
}

Tnode.indent () {
  S=${S:+$NL    }${S//$NL/$NL    }${S:+$NL  }
}

Tnode.interactive? () {
  [[ $- == *i* ]] && ! (( ${#FUNCNAME[*]} > 2 ))
}
