
@abstract class_name Graph extends Node
## Abstract class for structure of [Vertex] and [Edge] nodes

#@export_tool_button("Bake graph", "Callable") var bake = create_new_graph
#@export_tool_button("Clear graph", "Callable") var clear = clear_graph

@export_category("Required properties")
@export var actual_node_container : Node
@export var edge_container : Node
@export var adjacency_list : Array[EdgeData]

@export_category("Don't set these properties")
@export var vertices : Array[Vertex]
@export var edges : Array[Edge]

@abstract func bake_graph() -> void
@abstract func clear_graph()
@abstract func generate_graph()

func create_new_graph():
	# clear graph and wait for all nodes to be freed
	await clear_graph()
	# bake new graph
	bake_graph.call_deferred()

## Searches for a [Vertex] by a given [String]. Returns null if not found
func get_vertex_by_name(id : String) -> Vertex:
	for vertex in vertices:
		if vertex.name == id:
			return vertex
	return null
