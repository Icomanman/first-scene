extends Node

# Simple O(1) registry: map id -> node, group -> Array(node)
var by_id: Dictionary = {}
var by_group: Dictionary = {}

func register(node: Node, id: Variant = null, groups: Array = []) -> void:
    var key = id if id != null else node.get_instance_id()
    by_id[key] = node
    if groups:
        for g in groups:
            if not by_group.has(g):
                by_group[g] = []
            by_group[g].append(node)

func unregister(node_or_id: Variant) -> void:
    var node: Node = null
    if typeof(node_or_id) in [TYPE_INT, TYPE_STRING]:
        if by_id.has(node_or_id):
            node = by_id[node_or_id]
            by_id.erase(node_or_id)
    else:
        node = node_or_id
        # remove from by_id (reverse lookup)
        for k in by_id.keys():
            if by_id[k] == node:
                by_id.erase(k)
                break
    if node:
        for g in by_group.keys():
            if node in by_group[g]:
                by_group[g].erase(node)
                if by_group[g].empty():
                    by_group.erase(g)

func get_by_id(id: Variant) -> Node:
    return by_id.get(id, null)

func get_by_group(group_name: String) -> Array:
    return by_group.get(group_name, [])