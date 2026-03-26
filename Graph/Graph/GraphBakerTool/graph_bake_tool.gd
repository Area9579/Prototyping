@tool
class_name GraphBakeTool extends Node

@export var graph : Graph:
	set(value):
		graph = value
		notify_property_list_changed()
		update_configuration_warnings()


@export_category("Editor Baking")
@export_tool_button("Bake graph", "Callable") var bake = bake_graph
@export_tool_button("Clear graph", "Callable") var clear = clear_graph

#region baking options
# NOTE: This doesn't do anything yet
var are_edges_visible : bool = true

func _get_property_list() -> Array[Dictionary]:
	var property_list : Array[Dictionary] = []
	
	if graph is Graph2D:
		property_list.append({
			"name": "Options/Visible Edges",
			"type": TYPE_BOOL,
		})
	
	return property_list

func _set(property: StringName, value: Variant) -> bool:
	var should_property_be_visible : bool = true
	
	match property:
		"Options/Visible Edges":
			are_edges_visible = value
			notify_property_list_changed()
		_:
			should_property_be_visible = false
	
	return should_property_be_visible

func _get(property: StringName) -> Variant:
	match property:
		"Options/Visible Edges":
			return are_edges_visible
	
	return null
#endregion

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	
	if graph == null:
		warnings.append("Please set a graph to bake")
	
	return warnings
		
## NOTE: Because tool scripts are silly and don't like running code in a node that exists under the edited
## scene root, this function takes the graph you already made, copies its data into a graph that doesn't exist
## in the tree yet, and then bakes data using that graph's generated information.
## 
## The generated graph will show up under the [GraphBakeTool]
func bake_graph() -> void:
	# create a new graph that doesn't yet exist in the edited scene root
	await copy_data_to_new_graph()
	
	# clear and then generate the graph connections in sequence w/ awaits
	await graph.clear_graph()
	await graph.generate_graph()
	
	# goes through and updates all the added nodes
	await update_editor_interface()
	
	# after the graph is edited, since its not a toolscript, no more code can be run in it
	# (this line needs to appear last)
	EditorInterface.edit_node(graph)
	
	print_rich('[color=light_green]Graph has been baked![/color]')


func clear_graph():
	await copy_data_to_new_graph()
	
	# clear and then generate the graph connections in sequence w/ awaits
	await graph.clear_graph()
	# goes through and updates all the added nodes
	#await update_editor_interface()
	# after the graph is edited, since its not a toolscript, no more code can be run in it
	# (this line needs to appear last)
	EditorInterface.edit_node(graph)
	print_rich('[color=light_blue]Graph has been cleared![/color]')

func update_editor_interface() -> void:
	for edge in graph.edges:
		if edge.is_inside_tree():
			EditorInterface.edit_node(edge)
	
	for vertex in graph.vertices:
		if vertex.is_inside_tree():
			EditorInterface.edit_node(vertex)
	
	await get_tree().process_frame
	return

func copy_data_to_new_graph() -> void:
	if graph == null:
		return
	
	# make a new graph
	var new_graph : Graph2D = Graph2D.new()
	
	# copy data from old graph to new graph
	new_graph.edges = graph.edges.duplicate() as Array[Edge]
	new_graph.vertices = graph.vertices.duplicate() as Array[Vertex]
	new_graph.adjacency_list = graph.adjacency_list.duplicate() as Array[EdgeData]
	new_graph.actual_node_container = graph.actual_node_container
	new_graph.edge_container = graph.edge_container
	new_graph.name = graph.name
	
	# kill old graph
	graph.queue_free.call_deferred()
	if graph.is_inside_tree():
		await graph.tree_exited
	
	# pretend that we didn't kill the old graph
	graph = new_graph
	
	add_child.call_deferred(graph)
	if !graph.is_inside_tree():
		await graph.tree_entered
	
	graph.owner = get_tree().edited_scene_root
	await get_tree().process_frame
