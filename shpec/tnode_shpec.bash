IFS=$'\n'
set -o noglob

shpec_parent=$(dirname $BASH_SOURCE)/..
source $shpec_parent/shpec/shpec-helper.bash
source $shpec_parent/lib/tnode.bash

describe tnode.left
  it "gets the left of a node"
    tnode.new
    root=$S

    tnode.setLeft $root 1

    assert equal 1 $S
  ti
end_describe

describe tnode.name
  it "gets the name of a node"
    tnode.new sample
    root=$S

    tnode.name $root

    assert equal sample $S
  ti
end_describe

describe tnode.new
  it "has a no-arg constructor which returns the first ref"
    tnode.new
    assert equal 1 $S
  ti

  it "has a no-arg constructor which returns the second ref"
    tnode.new
    tnode.new
    assert equal 2 $S
  ti

  it "has a no-arg constructor which sets no parent"
    tnode.new
    declare -n parent=Tnode_parent$S
    assert equal 0 $parent
  ti

  it "has a no-arg constructor which sets no children"
    tnode.new
    declare -n ref=Tnode_children$S
    assert equal 0 ${#ref[*]}
  ti

  it "has a no-arg constructor which sets no left"
    tnode.new
    declare -n ref=Tnode_left$S
    assert equal 0 "$ref"
  ti

  it "has a no-arg constructor which sets no right"
    tnode.new
    declare -n ref=Tnode_right$S
    assert equal 0 "$ref"
  ti

  it "has a single-value constructor"
    tnode.new sample
    local -n name=Tnode_name$S
    assert equal sample $name
  ti
end_describe

describe tnode.number
  it "numbers a node"
    tnode.new root
    root=$S

    tnode.setLeft $root 0
    tnode.setRight $root 1

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 1,
  "children": []
}
END
    tnode.number $root 0
    tnode.toJson $root
    assert equal "$expected" "$S"
  ti

  it "numbers a node and child"
    tnode.new root
    root=$S

    tnode.new child
    child=$S

    tnode.setParent $child $root

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 3,
  "children": [
    {
      "name": "child",
      "left": 1,
      "right": 2,
      "children": []
    }
  ]
}
END
    tnode.number $root 0
    tnode.toJson $root
    assert equal "$expected" "$S"
  ti

  it "numbers a node and two children"
    tnode.new root
    root=$S

    tnode.new child1
    child1=$S

    tnode.new child2
    child2=$S

    tnode.setParent $child1 $root
    tnode.setParent $child2 $root

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 5,
  "children": [
    {
      "name": "child1",
      "left": 1,
      "right": 2,
      "children": []
    },
    {
      "name": "child2",
      "left": 3,
      "right": 4,
      "children": []
    }
  ]
}
END
    tnode.number $root 0
    tnode.toJson $root
    assert equal "$expected" "$S"
  ti
end_describe

describe tnode.parent
  it "gets the parent of a root"
    tnode.new
    root=$S

    tnode.new
    parent=$S

    tnode.setParent $root $parent
    tnode.parent $root

    assert equal $parent $S
  ti
end_describe

describe tnode.remove
  it "removes a root's list of children"
    tnode.new
    root=$S

    tnode.remove $root

    ! declare -p Tnode_children$root &>/dev/null

    assert equal 0 $?
  ti

  it "removes a root's parent reference"
    tnode.new
    root=$S

    tnode.remove $root

    ! declare -p Tnode_parent$root &>/dev/null
    assert equal 0 $?
  ti

  it "removes a root's name"
    tnode.new
    root=$S

    tnode.remove $root

    ! declare -p Tnode_name$root &>/dev/null
    assert equal 0 $?
  ti

  it "removes a root's left"
    tnode.new
    root=$S

    tnode.remove $root

    ! declare -p Tnode_left$root &>/dev/null
    assert equal 0 $?
  ti

  it "removes a root's right"
    tnode.new
    root=$S

    tnode.remove $root

    ! declare -p Tnode_right$root &>/dev/null
    assert equal 0 $?
  ti

  it "removes the parent's child reference"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root
    tnode.remove $child

    declare -n ref=Tnode_children$root
    assert equal 0 ${#ref[*]}
  ti

  it "removes a child's list of children"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root
    tnode.remove $root

    ! declare -p Tnode_children$child &>/dev/null
    assert equal 0 $?
  ti

  it "removes a child's parent reference"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root
    tnode.remove $root

    ! declare -p Tnode_parent$child &>/dev/null
    assert equal 0 $?
  ti

  it "removes a child's name"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root
    tnode.remove $root

    ! declare -p Tnode_name$child &>/dev/null
    assert equal 0 $?
  ti

  it "removes a grandchild's list of children"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.new
    grandchild=$S

    tnode.setParent $child       $root
    tnode.setParent $grandchild  $child
    tnode.remove $root

    ! declare -p Tnode_children$grandchild &>/dev/null
    assert equal 0 $?
  ti

  it "removes a grandchild's parent reference"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.new
    grandchild=$S

    tnode.setParent $child $root
    tnode.setParent $grandchild $child
    tnode.remove $root

    ! declare -p Tnode_parent$grandchild &>/dev/null
    assert equal 0 $?
  ti

  it "removes a grandchild's name"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.new
    grandchild=$S

    tnode.setParent $child       $root
    tnode.setParent $grandchild  $child
    tnode.remove $root

    ! declare -p Tnode_name$grandchild &>/dev/null
    assert equal 0 $?
  ti
end_describe

describe tnode.right
  it "gets the right of a node"
    tnode.new
    root=$S

    tnode.setRight $root 1

    assert equal 1 $S
  ti
end_describe

describe tnode.setLeft
  it "sets the left of a node"
    tnode.new
    root=$S

    tnode.setLeft $root 1

    local -n left=Tnode_left$root
    assert equal 1 $left
  ti
end_describe

describe tnode.setName
  it "sets the name of a node"
    tnode.new
    root=$S

    tnode.setName $root sample

    local -n name=Tnode_name$root
    assert equal sample $name
  ti
end_describe

describe tnode.setParent
  it "sets the parent of a child"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root

    local -n parent=Tnode_parent$child
    assert equal $root $parent
  ti

  it "sets the child of the root"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root

    declare -n ref=Tnode_children$root

    assert equal 1 ${#ref[*]}
  ti

  it "errors on 0 parent"
    tnode.new
    ! tnode.setParent $S 0
    assert equal 0 $?
  ti
end_describe

describe tnode.setRight
  it "sets the right of a node"
    tnode.new
    root=$S

    tnode.setRight $root 1

    local -n right=Tnode_right$root
    assert equal 1 $right
  ti
end_describe

describe tnode.toJson
  it "renders an empty childlist"
    tnode.new root
    root=$S

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 0,
  "children": []
}
END

    tnode.toJson $root

    assert equal "$expected" "$S"
  ti

  it "renders a left and right"
    tnode.new root
    root=$S

    tnode.setLeft $root 1
    tnode.setRight $root 2

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 1,
  "right": 2,
  "children": []
}
END

    tnode.toJson $root

    assert equal "$expected" "$S"
  ti

  it "renders a child"
    tnode.new root
    root=$S

    tnode.new child
    child=$S

    tnode.setParent $child $root

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 0,
  "children": [
    {
      "name": "child",
      "left": 0,
      "right": 0,
      "children": []
    }
  ]
}
END

    tnode.toJson $root
    assert equal "$expected" "$S"
  ti

  it "renders lefts and rights"
    tnode.new root
    root=$S

    tnode.new child
    child=$S

    tnode.setParent $child $root
    tnode.setLeft $root 0
    tnode.setRight $root 3
    tnode.setLeft $child 1
    tnode.setRight $child 2

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 3,
  "children": [
    {
      "name": "child",
      "left": 1,
      "right": 2,
      "children": []
    }
  ]
}
END

    tnode.toJson $root
    assert equal "$expected" "$S"
  ti

  it "renders two children"
    tnode.new root
    root=$S

    tnode.new child1
    child1=$S

    tnode.new child2
    child2=$S

    tnode.setParent $child1 $root
    tnode.setParent $child2 $root

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 0,
  "children": [
    {
      "name": "child1",
      "left": 0,
      "right": 0,
      "children": []
    },
    {
      "name": "child2",
      "left": 0,
      "right": 0,
      "children": []
    }
  ]
}
END

    tnode.toJson $root
    assert equal "$expected" "$S"
  ti

  it "renders a grandchild"
    tnode.new root
    root=$S

    tnode.new child
    child=$S

    tnode.new grandchild
    grandchild=$S

    tnode.setParent $child      $root
    tnode.setParent $grandchild $child

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 0,
  "children": [
    {
      "name": "child",
      "left": 0,
      "right": 0,
      "children": [
        {
          "name": "grandchild",
          "left": 0,
          "right": 0,
          "children": []
        }
      ]
    }
  ]
}
END

    tnode.toJson $root
    assert equal "$expected" "$S"
  ti

  it "renders a tree"
    tnode.new root
    root=$S

    tnode.new child1
    child1=$S

    tnode.new child2
    child2=$S

    tnode.new grandchild1
    grandchild1=$S

    tnode.new grandchild2
    grandchild2=$S

    tnode.new grandchild3
    grandchild3=$S

    tnode.setParent $child1       $root
    tnode.setParent $child2       $root
    tnode.setParent $grandchild1  $child1
    tnode.setParent $grandchild2  $child2
    tnode.setParent $grandchild3  $child2

    ! read -rd '' expected <<'END'
{
  "name": "root",
  "left": 0,
  "right": 0,
  "children": [
    {
      "name": "child1",
      "left": 0,
      "right": 0,
      "children": [
        {
          "name": "grandchild1",
          "left": 0,
          "right": 0,
          "children": []
        }
      ]
    },
    {
      "name": "child2",
      "left": 0,
      "right": 0,
      "children": [
        {
          "name": "grandchild2",
          "left": 0,
          "right": 0,
          "children": []
        },
        {
          "name": "grandchild3",
          "left": 0,
          "right": 0,
          "children": []
        }
      ]
    }
  ]
}
END

    tnode.toJson $root
    assert equal "$expected" "$S"
  ti
end_describe

describe tnode.walk
  it "names the roots of a single-level tree"
    tnode.new
    root=$S

    tnode.walk $root

    assert equal 1 "${A[*]}"
  ti

  it "names the roots of a two-level tree"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.setParent $child $root
    tnode.walk $root
    actual=( ${A[*]} )

    expected=( $root $child )
    assert equal "${expected[*]}" "${actual[*]}"
  ti

  it "names the roots of a three-level tree"
    tnode.new
    root=$S

    tnode.new
    child=$S

    tnode.new
    grandchild=$S

    tnode.setParent $child       $root
    tnode.setParent $grandchild  $child
    tnode.walk $root
    actual=( ${A[*]} )

    expected=( $root $child $grandchild )
    assert equal "${expected[*]}" "${actual[*]}"
  ti
end_describe

describe Tnode.children
  it "renders a child"
    tnode.new root
    root=$S

    tnode.new child
    child=$S

    tnode.setParent $child $root

    ! read -rd '' expected <<'END'
{
  "name": "child",
  "left": 0,
  "right": 0,
  "children": []
}
END

    Tnode.children $root
    assert equal "$expected" "$S"
  ti

  it "renders two children"
    tnode.new root
    root=$S

    tnode.new child1
    child1=$S

    tnode.new child2
    child2=$S

    tnode.setParent $child1 $root
    tnode.setParent $child2 $root

    ! read -rd '' expected <<'END'
{
  "name": "child1",
  "left": 0,
  "right": 0,
  "children": []
},
{
  "name": "child2",
  "left": 0,
  "right": 0,
  "children": []
}
END

    Tnode.children $root
    assert equal "$expected" "$S"
  ti
end_describe
