class_name Djikstras extends PathFinder
## Implementation of the [Algorithm] class to find the shortest path between nodes

var queue : Array[Vertex]
var vertices : Array[Vertex]
var curr_vertex : Vertex

func find_path(start : Vertex, target : Vertex, graph : Graph) -> Array[Vertex]:
	if start == null || target == null:
		printerr(self, ": Cannot find path between invalid vertices")
	queue.clear()
	vertices = graph.get_vertices()
	
	# set visited to false & distance to infinity for each vertex
	for vertex in vertices:
		vertex.set_visited(false)
		vertex.set_dist(INF)
		vertex.set_previous(null)
	
	# set up the start vertex
	start.set_dist(0.0)
	
	queue.push_back(start)
	
	# set up vars to be reused in the while loop
	var con_dict : Dictionary[Edge, Vertex]
	var connected_vertex : Vertex
	#print('', )
	while !queue.is_empty():
		# grab next node & set to be visited
		curr_vertex = queue.pop_front()
		curr_vertex.set_visited(true)
		
		# grab new connections
		con_dict = curr_vertex.get_connection_dict()
		
		# iterate thru each edge and grab the connected vertex from con_dict
		for edge in curr_vertex.get_edges():
			connected_vertex = con_dict.get(edge)
			# checking if we found a new, shorter route
			if connected_vertex.get_dist() > curr_vertex.get_dist() + edge.get_weight():
				connected_vertex.set_dist(curr_vertex.get_dist() + edge.get_weight())
				connected_vertex.set_previous(curr_vertex)
			
			# pushing connected vertex to the queue if we haven't visited it yet
			if !connected_vertex.get_visited():
				queue.push_back(connected_vertex)
				
			# break if we found the target node, this needs to be last so the target vertex
			# has a previous value
			if connected_vertex == target:
				break
	
	var path : Array[Vertex] = []
	if target.previous != null:
	# pack the list of room nodes in the shortest path to be returned
		curr_vertex = target
		start.previous = start
		while curr_vertex != start:
			path.append(curr_vertex)
			curr_vertex = curr_vertex.get_previous()
	
	return path
