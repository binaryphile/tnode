IFS=$'\n'
set -o noglob

shpec_parent=$(dirname $BASH_SOURCE)/..
source $shpec_parent/shpec/shpec-helper.bash
source $shpec_parent/lib/tNode.bash

describe tNode.leaf?
  it "returns true for a leaf"
    tNode.new

    tNode.leaf? $S

    assert equal 0 $?
  ti

  it "returns false for a non-leaf"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root
    ! tNode.leaf? $root

    assert equal 0 $?
  ti
end_describe

describe tNode.new
  it "has a no-arg constructor which returns the first ref"
    tNode.new
    assert equal 1 $S
  ti

  it "has a no-arg constructor which returns the second ref"
    tNode.new
    tNode.new
    assert equal 2 $S
  ti

  it "has a no-arg constructor which sets no parent"
    tNode.new
    declare -n parent=TNode_parent$S
    assert equal 0 $parent
  ti

  it "has a no-arg constructor which sets no children"
    tNode.new
    declare -n ref=TNode_children$S
    assert equal 0 ${#ref[*]}
  ti

  it "has a single-value constructor"
    tNode.new sample
    local -n name=TNode_name$S
    assert equal sample $name
  ti
end_describe

describe tNode.parent
  it "gets the parent of a root"
    tNode.new
    root=$S

    tNode.new
    parent=$S

    tNode.setParent $root $parent
    tNode.parent $root

    assert equal $parent $S
  ti
end_describe

describe tNode.remove
  it "removes a root's list of children"
    tNode.new
    root=$S

    tNode.remove $root

    ! declare -p TNode_children$root &>/dev/null

    assert equal 0 $?
  ti

  it "removes a root's parent reference"
    tNode.new
    root=$S

    tNode.remove $root

    ! declare -p TNode_parent$root &>/dev/null
    assert equal 0 $?
  ti

  it "removes a root's name"
    tNode.new
    root=$S

    tNode.remove $root

    ! declare -p TNode_name$root &>/dev/null
    assert equal 0 $?
  ti

  it "removes the parent's child reference"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root
    tNode.remove $child

    declare -n ref=TNode_children$root
    assert equal 0 ${#ref[*]}
  ti

  it "removes a child's list of children"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root
    tNode.remove $root

    ! declare -p TNode_children$child &>/dev/null
    assert equal 0 $?
  ti

  it "removes a child's parent reference"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root
    tNode.remove $root

    ! declare -p TNode_parent$child &>/dev/null
    assert equal 0 $?
  ti

  it "removes a child's name"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root
    tNode.remove $root

    ! declare -p TNode_name$child &>/dev/null
    assert equal 0 $?
  ti

  it "removes a grandchild's list of children"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.new
    grandchild=$S

    tNode.setParent $child       $root
    tNode.setParent $grandchild  $child
    tNode.remove $root

    ! declare -p TNode_children$grandchild &>/dev/null
    assert equal 0 $?
  ti

  it "removes a grandchild's parent reference"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.new
    grandchild=$S

    tNode.setParent $child $root
    tNode.setParent $grandchild $child
    tNode.remove $root

    ! declare -p TNode_parent$grandchild &>/dev/null
    assert equal 0 $?
  ti

  it "removes a grandchild's name"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.new
    grandchild=$S

    tNode.setParent $child       $root
    tNode.setParent $grandchild  $child
    tNode.remove $root

    ! declare -p TNode_name$grandchild &>/dev/null
    assert equal 0 $?
  ti
end_describe

describe tNode.setParent
  it "sets the parent of a child"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root

    local -n parent=TNode_parent$child
    assert equal $root $parent
  ti

  it "sets the child of the root"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root

    declare -n ref=TNode_children$root

    assert equal 1 ${#ref[*]}
  ti

  it "errors on 0 parent"
    tNode.new
    ! tNode.setParent $S 0
    assert equal 0 $?
  ti
end_describe

describe tNode.setName
  it "sets the value of a root"
    tNode.new
    root=$S

    tNode.setName $root sample

    local -n name=TNode_name$root
    assert equal sample $name
  ti
end_describe

describe tNode.name
  it "gets the name of a node"
    tNode.new sample
    root=$S

    tNode.name $root

    assert equal sample $S
  ti
end_describe

describe tNode.walk
  it "names the roots of a single-level tree"
    tNode.new
    root=$S

    tNode.walk $root

    assert equal 1 "${A[*]}"
  ti

  it "names the roots of a two-level tree"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.setParent $child $root
    tNode.walk $root
    actual=( ${A[*]} )

    expected=( $root $child )
    assert equal "${expected[*]}" "${actual[*]}"
  ti

  it "names the roots of a three-level tree"
    tNode.new
    root=$S

    tNode.new
    child=$S

    tNode.new
    grandchild=$S

    tNode.setParent $child       $root
    tNode.setParent $grandchild  $child
    tNode.walk $root
    actual=( ${A[*]} )

    expected=( $root $child $grandchild )
    assert equal "${expected[*]}" "${actual[*]}"
  ti
end_describe

describe TNode.children
  it "renders a child"
    tNode.new root
    root=$S

    tNode.new child
    child=$S

    tNode.setParent $child $root

    ! read -rd '' expected <<'END'
{
  "name": "child",
  "children": []
}
END

    TNode.children $root
    assert equal "$expected" "$S"
  ti

  it "renders two children"
    tNode.new root
    root=$S

    tNode.new child1
    child1=$S

    tNode.new child2
    child2=$S

    tNode.setParent $child1 $root
    tNode.setParent $child2 $root

    ! read -rd '' expected <<'END'
{
  "name": "child1",
  "children": []
},
{
  "name": "child2",
  "children": []
}
END

    TNode.children $root
    assert equal "$expected" "$S"
  ti
end_describe

describe TNode.object
  it "renders an empty childlist"
    tNode.new root
    root=$S

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "children": []
}
END

    TNode.object $root

    assert equal "$expected" "$S"
  ti

  it "renders a child"
    tNode.new root
    root=$S

    tNode.new child
    child=$S

    tNode.setParent $child $root

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "children": [
    {
      "name": "child",
      "children": []
    }
  ]
}
END

    TNode.object $root
    assert equal "$expected" "$S"
  ti

  it "renders two children"
    tNode.new root
    root=$S

    tNode.new child1
    child1=$S

    tNode.new child2
    child2=$S

    tNode.setParent $child1 $root
    tNode.setParent $child2 $root

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "children": [
    {
      "name": "child1",
      "children": []
    },
    {
      "name": "child2",
      "children": []
    }
  ]
}
END

    TNode.object $root
    assert equal "$expected" "$S"
  ti

  it "renders a grandchild"
    tNode.new root
    root=$S

    tNode.new child
    child=$S

    tNode.new grandchild
    grandchild=$S

    tNode.setParent $child      $root
    tNode.setParent $grandchild $child

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "children": [
    {
      "name": "child",
      "children": [
        {
          "name": "grandchild",
          "children": []
        }
      ]
    }
  ]
}
END

    TNode.object $root
    assert equal "$expected" "$S"
  ti

  it "renders a tree"
    tNode.new root
    root=$S

    tNode.new child1
    child1=$S

    tNode.new child2
    child2=$S

    tNode.new grandchild1
    grandchild1=$S

    tNode.new grandchild2
    grandchild2=$S

    tNode.new grandchild3
    grandchild3=$S

    tNode.setParent $child1       $root
    tNode.setParent $child2       $root
    tNode.setParent $grandchild1  $child1
    tNode.setParent $grandchild2  $child2
    tNode.setParent $grandchild3  $child2

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "children": [
    {
      "name": "child1",
      "children": [
        {
          "name": "grandchild1",
          "children": []
        }
      ]
    },
    {
      "name": "child2",
      "children": [
        {
          "name": "grandchild2",
          "children": []
        },
        {
          "name": "grandchild3",
          "children": []
        }
      ]
    }
  ]
}
END

    TNode.object $root
    assert equal "$expected" "$S"
  ti
end_describe
