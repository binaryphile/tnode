set -o noglob

# A node is referred to by its node id and the two terms are used
# interchangeably here.

# TNode_next is the id of the next unallocated self
declare -i TNode_next=1

# NL is newline
NL=$'\n'

tNode.leaf? () {
  local -n children=TNode_children$1

  ! (( ${#children[*]} ))
}

# new allocates a new node.  If a value is supplied, it becomes the value of
# the new node.
tNode.new () {
  local name=${1:-}
  local self

  self=$TNode_next
  (( TNode_next++ ))

  declare -Ag TNode_children$self="()"
  declare -g TNode_parent$self=0
  declare -g TNode_name$self=$name

  S=$self
}

# parent returns the parent of the given self.
tNode.parent () {
  local -n parent=TNode_parent$1

  S=$parent
}

# remove removes a node and all of its children
tNode.remove () {
  local self=$1
  local -n children=TNode_children$self parent=TNode_parent$self
  local child

  for child in ${!children[*]}; do
    tNode.remove $child
  done

  (( parent )) && unset -v TNode_children$parent[$self]

  unset -v TNode_children$self
  unset -v TNode_parent$self
  unset -v TNode_name$self
}

# setParent sets the parent of the given self to the self in the second
# argument.
tNode.setParent () {
  local self=$1 newParent=$2
  local -n parent=TNode_parent$self

  (( newParent )) || return

  # bail if nothing to do
  (( $newParent == $parent )) && return

  parent=$newParent
  printf -v TNode_children$newParent[$self] %s ''
}

# setName sets the name of the given self to the second argument.
tNode.setName () {
  printf -v TNode_name$1 %s $2
}

tNode.toJson () {
  local self=$1
  local format

  ! read -rd '' format <<'END'
{
  "root": %s
}
END

  TNode.fields $self
  printf -v S "$format" "${S//$NL/$NL  }"
}

# name returns the name of the given self.
tNode.name () {
  local -n name=TNode_name$1

  S=$name
}

# walk returns the nodes of the subtree including the start node.
tNode.walk () {
  local self=$1
  local -n children=TNode_children$self
  local child results=()

  for child in ${!children[*]}; do
    tNode.walk $child
    results+=( ${A[*]} )
  done
  A=( $self ${results[*]} )
}

TNode.children () {
  local -n children=TNode_children$1
  local child results=()

  for child in ${!children[*]}; do
    TNode.object $child
    results+=( "$S" )
  done

  printf -v S "%s,$NL" "${results[@]}"
  S=${S%,$NL}
}

TNode.object () {
  local self=$1
  local format name

  ! read -rd '' format <<'END'
{
  "name": "%s",
  "children": [%s]
}
END

  tNode.name $self
  name=$S

  TNode.children $self
  printf -v S "$format" $name "${S:+$NL    }${S//$NL/$NL    }${S:+$NL  }"
}
