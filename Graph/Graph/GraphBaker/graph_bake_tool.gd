@tool
class_name GraphBakeTool extends Node

signal finished_editing

@export var graph : Graph:
	set(value):
		graph = value
		notify_property_list_changed()


@export_category("Editor Baking")
@export_tool_button("Bake graph", "Callable") var bake = bake_graph
@export_tool_button("Clear graph", "Callable") var clear = clear_graph

# Conditional properties to set
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

func bake_graph() -> void:
	if graph == null:
		return
	
	var new_graph : Graph2D = Graph2D.new()
	
	new_graph.edges = graph.edges.duplicate()
	new_graph.vertices = graph.vertices.duplicate()
	new_graph.adjacency_list = graph.adjacency_list.duplicate()
	new_graph.actual_node_container = graph.actual_node_container
	new_graph.edge_container = graph.edge_container
	new_graph.name = graph.name
	
	graph.queue_free.call_deferred()
	if graph.is_inside_tree():
		await graph.tree_exited
	
	graph = new_graph
	
	
	add_child.call_deferred(graph)
	if !graph.is_inside_tree():
		await graph.tree_entered
	
	graph.owner = get_tree().edited_scene_root
	
	await graph.clear_graph()
	await graph.generate_graph()
	await update_editor_interface()
	
	EditorInterface.edit_node(graph)
	
	print_rich('[color=light_green]Graph has been baked![/color]')

func update_editor_interface() -> void:
	print('updating editor interface')
	for edge in graph.edges:
		EditorInterface.edit_node(edge)
		#if edge != null:
			#EditorInterface.edit_node(edge.center_marker)
	
	for vertex in graph.vertices:
		EditorInterface.edit_node(vertex)
	
	EditorInterface.edit_node(graph)
	print('finished updating editor interface')
	finished_editing.emit()
	await get_tree().process_frame
	return
	

func clear_graph():
	pass
