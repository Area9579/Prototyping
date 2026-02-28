@tool
class_name Graph2D extends Graph

func bake_graph() -> void:
	var actual_nodes : Array[Node2D]
	var start_node : Node2D
	var end_node : Node2D
	var start_vertex : Vertex2D
	var end_vertex : Vertex2D
	var new_edge : Edge2D
	var id : int = 0
	
	# clearing previous data that might be stored in this graph
	vertices.clear()
	edges.clear()
	
	# making sure all nodes in tree derive from Node2D
	for node in actual_node_container.get_children():
		if node is not Node2D:
			printerr(self, ": ", node, " under ActualNodeContainer is not a Node2D. Skipping adding this node")
			continue
		actual_nodes.append(node as Node2D)
	
	for edge_data in adjacency_list:
		# ensure all edges match with real nodes in scene tree
		start_node = get_node_by_name(edge_data.start, actual_nodes)
		end_node = get_node_by_name(edge_data.end, actual_nodes)
		
		# error handling: checking for all edges match with real nodes in scene tree
		if start_node == null:
			printerr(self, ": Edge data: ", edge_data.start, " does not match with actual node in scene tree")
			continue
		if end_node == null:
			printerr(self, ": Edge data: ", edge_data.end, " does not match with actual node in scene tree")
			continue
		# error handling: checking that all actual nodes have 'vertex' property
		if 'vertex' not in start_node:
			printerr(self, ": Actual node: ", start_node, " does not have vertex property")
			continue
		if 'vertex' not in end_node:
			printerr(self, ": Actual node: ", end_node, " does not have vertex property")
			continue
		
		# grabbing start and end vertex
		start_vertex = get_vertex_by_name(start_node.name)
		end_vertex = get_vertex_by_name(end_node.name)
		
		# initializing start and end vertex if they dont exist yet
		if start_vertex == null:
			start_vertex = Vertex2D.new().with_data(start_node, start_node.name)
			start_node.vertex = start_vertex
			start_node.add_child(start_vertex)
			start_vertex.owner = get_tree().edited_scene_root
			add(start_vertex)
			# telling editor to update this node so data is saved to scene
			EditorInterface.edit_node(start_vertex)
			EditorInterface.edit_node(self)
		if end_vertex == null:
			end_vertex = Vertex2D.new().with_data(end_node, end_node.name)
			end_node.vertex = end_vertex
			end_node.add_child(end_vertex)
			end_vertex.owner = get_tree().edited_scene_root
			add(end_vertex)
			# telling editor to update this node so data is saved to scene
			EditorInterface.edit_node(end_vertex)
			EditorInterface.edit_node(self)
			
		
		# error handling: if connection already exists, don't make another
		if start_vertex.get_connnected_vertices().has(end_vertex):
			continue
		
		# adding edge IFF one doesn't exist already
		new_edge = Edge2D.new().with_data(start_vertex, end_vertex, edge_data.weight, str(id))
		id += 1
		start_vertex.add_edge(new_edge)
		end_vertex.add_edge(new_edge)
		add_edge(new_edge)
		edge_container.add_child(new_edge)
		new_edge.owner = get_tree().edited_scene_root
		
		# telling editor to update nodes so data is saved to scene
		EditorInterface.edit_node(start_vertex)
		EditorInterface.edit_node(end_vertex)
		EditorInterface.edit_node(new_edge)
		EditorInterface.edit_node(new_edge.center_marker)
		EditorInterface.edit_node(new_edge.interaction_handler)
		EditorInterface.edit_node(self)
	
	
	print_rich('[color=light_green]Graph has been baked![/color]')

func clear_graph():
	# free all edges
	for edge in edge_container.get_children():
		edge.call_deferred('queue_free')
		
	# wait for all edges to actually be freed
	if !edges.is_empty():
		await edges[0].tree_exited
	
	# free all vertices
	for vertex in vertices:
		vertex.call_deferred('queue_free')
		EditorInterface.edit_node(vertex)
	
	# wait for vertices to actually free
	if !vertices.is_empty():
		await vertices[0].tree_exited
	
	return

## Returns node in given list that matches by name to an ID
func get_node_by_name(id : String, nodes : Array[Node2D]) -> Node2D:
	for node in nodes:
		if node.name == id:
			return node
	return null
