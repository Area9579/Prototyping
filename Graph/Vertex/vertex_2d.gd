class_name Vertex2D extends Vertex

func calc_heuristic(target_vertex : Vertex) -> void:
	if target_vertex.get_actual_node() is not Node2D:
		printerr(self, ": Cannot calculate heuristic, target node is not 2D")
	if actual_node is not Node2D:
		printerr(self, ": Cannot calculate heuristic, start node is not 2D")
	
	heuristic = actual_node.global_position.distance_to(target_vertex.get_actual_node().global_position)
