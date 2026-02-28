class_name Edge extends Node
## Defines a connection between two [Vertex] objects. This object should be passed
## to both vertices in order for them to keep track of

@export var vertices : Array[Vertex] ## Both connected [Vertex] objects
@export var weight : float ## Cost of traversing this edge
@export var disabled : bool = false

## NOTE: This class needs to be initialized with the function [method with_data], although it looks optional
func _init() -> void: pass

func with_data(vertex1 : Vertex, vertex2 : Vertex, edge_weight : float, id : String) -> Edge:
	name = "Hallway" + id
	vertices.append(vertex1)
	vertices.append(vertex2)
	weight = edge_weight
	return self

func get_weight() -> float: return weight ## Returns the cost of traversing this edge
func get_vertices() -> Array[Vertex]: return vertices ## Returns the connected [Vertex] objects

func toggle_enable_state():
	match disabled:
		true:
			# enabling edge
			disabled = false
			return
		false:
			# disabling edge
			disabled = true
			return
