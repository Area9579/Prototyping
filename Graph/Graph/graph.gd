@abstract class_name Graph extends Node
## Abstract class for structure of [Vertex] and [Edge] nodes

@export_category("Required properties")
@export var actual_node_container : Node
@export var edge_container : Node
@export var adjacency_list : Array[EdgeData]

@export_category("Don't set these properties")
@export var vertices : Array[Vertex]
@export var edges : Array[Edge]

@abstract func clear_graph()
@abstract func generate_graph()

## Searches for a [Vertex] by a given [String]. Returns null if not found
func get_vertex_by_name(id : String) -> Vertex:
	for vertex in vertices:
		if vertex.name == id:
			return vertex
	return null
