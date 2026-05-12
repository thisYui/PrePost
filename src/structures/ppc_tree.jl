mutable struct PPCNode
    item::Union{Int,Nothing}
    count::Int
    parent::Union{PPCNode,Nothing}
    children::Vector{PPCNode}
    pre::Int
    post::Int
end

mutable struct PPCTree
    root::PPCNode
end

function PPCTree()
    return PPCTree(PPCNode(nothing, 0, nothing, PPCNode[], 0, 0))
end

function _find_child(node::PPCNode, item::Int)::Union{PPCNode,Nothing}
    for child in node.children
        child.item == item && return child
    end
    return nothing
end

function insert_transaction!(tree::PPCTree, transaction::Vector{Int})
    current = tree.root
    current.count += 1
    for item in transaction
        child = _find_child(current, item)
        if child === nothing
            child = PPCNode(item, 1, current, PPCNode[], 0, 0)
            push!(current.children, child)
        else
            child.count += 1
        end
        current = child
    end
    return tree
end

function assign_pre_post!(tree::PPCTree)
    pre_counter = Ref(0)
    post_counter = Ref(0)

    function visit!(node::PPCNode)
        pre_counter[] += 1
        node.pre = pre_counter[]
        for child in node.children
            visit!(child)
        end
        post_counter[] += 1
        node.post = post_counter[]
    end

    visit!(tree.root)
    return tree
end

function collect_nodes(tree::PPCTree)::Vector{PPCNode}
    nodes = PPCNode[]

    function visit!(node::PPCNode)
        for child in node.children
            push!(nodes, child)
            visit!(child)
        end
    end

    visit!(tree.root)
    return nodes
end
