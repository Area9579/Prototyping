@abstract class_name Vertex extends Node
@export var actual_node : Node
@export var edges : Array[Edge] ## List of connected nodes
var heuristic : float ## Estimated cost to get to target vertex
var dist : float ## Actual cost to travel to from starting vertex

var priority : float ## Importance priority of this node
var previous : Vertex ## Node which preceeds this node in desired route
var visited : bool = false ## Boolean value to determine if this node has been visited in a search already

## Calculates the heuristic for this node based on position alone
@abstract func calc_heuristic(target_vertex : Vertex) -> void

## NOTE: This node must be initialized using [method with_data] in order for node to be functional
func _init() -> void:
	pass

func with_data(connected_node : Node, new_name : String) -> Vertex2D:
	actual_node = connected_node as Node2D
	name = new_name
	return self

#region setters
func set_visited(new_visited : bool): visited = new_visited ## Sets [member visited] status
func set_previous(new_previous : Vertex): previous = new_previous ## Sets the previously visited [Vertex]
func set_dist(new_dist : float) -> void: dist = new_dist ## Sets the distance to this vertex
func add_edge(edge : Edge) -> void: edges.append(edge) ## Adds a new [Edge] to this vertex
func remove_edge(edge : Edge) -> void: edges.erase(edge) ## Removes a specific [Edge] from this vertex
#endregion

#region getters
func get_visited() -> bool: return visited ## Returns the [member visited] status
func get_previous() -> Vertex: return previous ## Returns the previous [Vertex] to this vertex
func get_edges() -> Array[Edge]: 
	var enabled_edges : Array[Edge]
	for edge in edges:
		if !edge.disabled:
			enabled_edges.append(edge)
	return enabled_edges ## Returns an [Array] of all the edges connected to this vertex
func get_priority() -> float: return priority ## Returns the priority of this node
func get_heuristic() -> float: return heuristic ## Returns the heuristic of this node
func get_dist() -> float: return dist ## Returns the distance to this node
func get_actual_node() -> Node: return actual_node ## Returns the node this [Vertex] represents
## Returns the [Vertex] objects connected to this [Vertex] by [Edge] objects.
func get_connnected_vertices() -> Array[Vertex]:
	var con_vertices : Array[Vertex]
	for edge in edges:
		for vertex in edge.get_vertices():
			if vertex == self:
				continue
			if "disabled" in edge: 
				if !edge.disabled:
					con_vertices.append(vertex)
			else:
				con_vertices.append(vertex)
	return con_vertices

func get_connection_dict() -> Dictionary[Edge, Vertex]:
	var con_vertices : Dictionary[Edge, Vertex]
	for edge in edges:
		if edge.disabled:
			continue
		for vertex in edge.get_vertices():
			if vertex != self:
				con_vertices.set(edge, vertex)
	return con_vertices

#endregion
