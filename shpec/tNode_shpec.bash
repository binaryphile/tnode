IFS=$'\n'
set -o noglob

shpec_parent=$(dirname $BASH_SOURCE)/..
source $shpec_parent/shpec/shpec-helper.bash
source $shpec_parent/lib/tNode.bash

# describe tNode.json
#   it "generates a one-level tree"
#     n=$'\n'
#
#     tNode.new root
#     tNode.json $R
#
#     assert equal "{$n  \"root\": [$n  ]$n}" "$R"
#   ti
#
#   it "generates a two-level tree"
#     n=$'\n'
#
#     tNode.new root
#     root=$R
#
#     tNode.new child
#     child=$R
#
#     tNode.setParent $child $root
#
#     tNode.json $root
#
#     assert equal "{$n  \"root\": \"child\"$n}" "$R"
#   ti
# end_describe

describe tNode.leaf?
  it "returns true for a leaf"
    tNode.new

    tNode.leaf? $R

    assert equal 0 $?
  ti

  it "returns false for a non-leaf"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.setParent $child $root
    ! tNode.leaf? $root

    assert equal 0 $?
  ti
end_describe

describe tNode.new
  it "has a no-arg constructor which returns the first ref"
    tNode.new
    assert equal 1 $R
  ti

  it "has a no-arg constructor which returns the second ref"
    tNode.new
    tNode.new
    assert equal 2 $R
  ti

  it "has a no-arg constructor which sets no parent"
    tNode.new
    assert equal 0 ${TNode_parents[$R]}
  ti

  it "has a no-arg constructor which sets no children"
    tNode.new
    assert equal '' "${TNode_children[$R]}"
  ti

  it "has a single-value constructor"
    tNode.new sample
    assert equal sample ${TNode_names[$R]}
  ti
end_describe

describe tNode.parent
  it "gets the parent of a root"
    tNode.new
    root=$R

    tNode.new
    parent=$R

    tNode.setParent $root $parent
    tNode.parent $root

    assert equal $parent $R
  ti
end_describe

describe tNode.remove
  it "removes a root's list of children"
    tNode.new
    root=$R

    tNode.remove $root

    assert equal '' "${!TNode_children[*]}"
  ti

  it "removes a root's parent reference"
    tNode.new
    root=$R

    tNode.remove $root

    assert equal '' "${!TNode_parents[*]}"
  ti

  it "removes a root's value"
    tNode.new
    root=$R

    tNode.remove $root

    assert equal '' "${!TNode_names[*]}"
  ti

  it "removes the parent's child reference"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.setParent $child $root
    tNode.remove $child

    assert equal '' "${TNode_children[$root]}"
  ti

  it "removes a child's list of children"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.setParent $child $root
    tNode.remove $root

    assert equal '' "${!TNode_children[*]}"
  ti

  it "removes a child's parent reference"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.setParent $child $root
    tNode.remove $root

    assert equal '' "${!TNode_parents[*]}"
  ti

  it "removes a child's values"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.setParent $child $root
    tNode.remove $root

    assert equal '' "${!TNode_names[*]}"
  ti

  it "removes a grandchild's list of children"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.new
    grandchild=$R

    tNode.setParent $child       $root
    tNode.setParent $grandchild  $child
    tNode.remove $root

    assert equal '' "${!TNode_children[*]}"
  ti

  it "removes a grandchild's parent reference"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.new
    grandchild=$R

    tNode.setParent $child $root
    tNode.setParent $grandchild $child
    tNode.remove $root

    assert equal '' "${!TNode_parents[*]}"
  ti

  it "removes a grandchild's values"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.new
    grandchild=$R

    tNode.setParent $child       $root
    tNode.setParent $grandchild  $child
    tNode.remove $root

    assert equal '' "${!TNode_names[*]}"
  ti
end_describe

describe tNode.setParent
  it "sets the parent of a root"
    tNode.new
    root=$R

    tNode.new
    parent=$R

    tNode.setParent $root $parent
    assert equal $parent ${TNode_parents[$root]}
  ti

  it "sets the child of the parent root"
    tNode.new
    root=$R

    tNode.new
    parent=$R

    tNode.setParent $root $parent

    assert equal "[$root]=\"\" " ${TNode_children[$parent]}
  ti

  it "errors on 0 parent"
    tNode.new
    ! tNode.setParent $R 0
    assert equal 0 $?
  ti
end_describe

describe tNode.setValue
  it "sets the value of a root"
    tNode.new
    root=$R

    tNode.setValue $root sample

    assert equal sample ${TNode_names[$root]}
  ti
end_describe

describe tNode.value
  it "gets the value of a root"
    tNode.new
    root=$R

    tNode.setValue $root sample
    tNode.value $root

    assert equal sample $R
  ti
end_describe

describe tNode.walk
  it "names the roots of a single-level tree"
    tNode.new
    root=$R

    tNode.walk $root

    assert equal "[0]=\"$root\"" $R
  ti

  it "names the roots of a two-level tree"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.setParent $child $root
    tNode.walk $root

    assert equal "[0]=\"$root\" [1]=\"$child\"" $R
  ti

  it "names the roots of a three-level tree"
    tNode.new
    root=$R

    tNode.new
    child=$R

    tNode.new
    grandchild=$R

    tNode.setParent $child       $root
    tNode.setParent $grandchild  $child
    tNode.walk $root

    assert equal "[0]=\"$root\" [1]=\"$child\" [2]=\"$grandchild\"" $R
  ti
end_describe

describe TNode.add
  it "adds an element to a serialized set"
    samples=()

    TNode.add samples[0] sample

    assert equal '[sample]="" ' ${samples[0]}
  ti
end_describe

describe TNode.remove
  it "removes an element from a serialized set"
    samples=()

    TNode.add    samples[0] sample
    TNode.remove samples[0] sample

    assert equal '' "${samples[0]}"
  ti
end_describe

describe TNode.repr
  it "serializes array values"
    samples=( zero )

    TNode.repr samples

    assert equal '[0]="zero"' $R
  ti

  it "serializes hash values"
    declare -A samples=( [zero]=0 )

    TNode.repr samples

    assert equal '[zero]="0" ' $R
  ti
end_describe
