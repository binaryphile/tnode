set -o noglob

# A self is referred to by its self id and the two terms are frequently used
# interchangeably here.

# TNode_children is an array of the children of selfs.  The self ids of the
# children are stored as keys in a hash.  The hash is serialized and stored as
# a string in TNode_children, using the parent self id as the index.
TNode_children=()

# TNode_names is an array of the parents of selfs.  The value of the self is
# stored in TNode_names, using the child self id as the index.
TNode_names=()

# TNode_parents is an array of the parents of selfs.  The self id of the parent
# is stored in TNode_parents, using the child self id as the index.
TNode_parents=()

# TNode_next is the id of the next unallocated self
declare -i TNode_next=1

tNode.leaf? () {
  local self=$1

  [[ -z ${TNode_children[$self]} ]]
}

# json returns a json representation of the tree's values
tNode.json () {
  local self=$1
  local n

  n=$'\n'
  R="{$n"
  [[ -n ${TNode_names[$self]:-} ]] && R+="  \"${TNode_names[$self]}\"\n"
  R+=}
}

# new allocates a new root self.  If a value is supplied, it becomes the value
# of the new self.
tNode.new () {
  local value=${1:-}
  local self

  self=$TNode_next

  TNode_children[$self]=''
  TNode_parents[$self]=0
  TNode_names[$self]=$value

  R=$TNode_next
  (( TNode_next++ ))
}

# parent returns the parent of the given self.
tNode.parent () {
  local self=$1

  R=${TNode_parents[$self]}
}

# remove removes a node and all of its children
tNode.remove () {
  local self=$1
  local child parent

  parent=${TNode_parents[$self]}
  local -A children="( ${TNode_children[$self]} )"

  for child in ${!children[*]}; do
    tNode.remove $child
  done

  unset -v TNode_children[$self]
  unset -v TNode_parents[$self]
  unset -v TNode_names[$self]

  (( parent )) && TNode.remove TNode_children[$parent] $self;:
}

# setParent sets the parent of the given self to the self in the second
# argument.
tNode.setParent () {
  local self=$1 parent=$2
  local oldParent

  (( parent > 0 )) || return

  # bail if nothing to do
  [[ $parent == ${TNode_parents[$self]} ]] && return

  # set parent
  oldParent=${TNode_parents[$self]}
  TNode_parents[$self]=$parent

  # add to children
  local -A children="( ${TNode_children[$parent]:-} )"
  children[$self]=''
  TNode.repr children
  TNode_children[$parent]=$R
}

# setValue sets the value of the given self to the second argument.
tNode.setValue () {
  local self=$1 value=$2

  TNode_names[$self]=$value
}

# value returns the value of the given self.
tNode.value () {
  local self=$1

  R=${TNode_names[$self]}
}

# walk returns the nodes of the subtree including the start node.
tNode.walk () {
  local self=$1
  local child nodes=()

  nodes=( $self )
  local -A children="( ${TNode_children[$self]} )"
  for child in ${!children[*]}; do
    tNode.walk $child
    local -a subnodes="( $R )"
    nodes+=( ${subnodes[*]} )
  done
  TNode.repr nodes
}

# add adds a value as a key to a serialized hash and reserializes it
TNode.add () {
  local -n Ref=$1
  local Key=$2

  local -A Hash="( $Ref )"
  Hash[$Key]=''
  TNode.repr Hash
  Ref=$R
}

# remove removes a value as a key from a serialized hash and reserializes it
TNode.remove () {
  local -n Ref=$1
  local Key=$2

  local -A Hash="( $Ref )"
  unset -v Hash[$Key]
  TNode.repr Hash
  Ref=$R
}

# repr serializes an array of the given name.
TNode.repr () {
  local Value=$(declare -p $1)

  Value=${Value#*=}
  R=${Value:1:-1}
}
