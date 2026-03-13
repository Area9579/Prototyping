@tool
class_name GraphBakeTool extends Node

signal finished_editing

@export_tool_button("Bake graph", "Callable") var bake = bake_graph
@export_tool_button("Clear graph", "Callable") var clear = clear_graph

@export_category("Required Properties")
@export var actual_node_container : Node
@export var edge_container : Node
@export var adjacency_list : Array[EdgeData]
@export var graph : Graph:
	set(value):
		graph = value
		notify_property_list_changed()

# Conditional properties to set
@export_category("Options")
var are_edges_visible : bool = true

func _get_property_list() -> Array[Dictionary]:
	var property_list : Array[Dictionary] = []
	
	if graph is Graph2D:
		property_list.append({
			"name": "Visible Edges",
			"type": TYPE_BOOL,
		})
	
	return property_list

func _set(property: StringName, value: Variant) -> bool:
	var should_property_be_visible : bool = true
	
	match property:
		"Visible Edges":
			are_edges_visible = value
			notify_property_list_changed()
		_:
			should_property_be_visible = false
	
	return should_property_be_visible

func _get(property: StringName) -> Variant:
	match property:
		"Visible Edges":
			return are_edges_visible
	
	return null

func bake_graph() -> void:
	if graph == null:
		return
	await graph.clear_graph()
	await update_editor_interface()
	await graph.generate_graph()
	
	#if are_edges_visible:
		#for edge in graph.edges:
			#if edge is not Edge2D:
				#continue
			#edge.draw_connection()
	
	await update_editor_interface()
	
	print_rich('[color=light_green]Graph has been baked![/color]')
	

func update_editor_interface() -> void:
	print('updating editor interface')
	for edge in graph.edges:
		EditorInterface.edit_node(edge)
		if edge != null:
			EditorInterface.edit_node(edge.center_marker)
	
	for vertex in graph.vertices:
		EditorInterface.edit_node(vertex)
	
	EditorInterface.edit_node(graph)
	print('finished updating editor interface')
	finished_editing.emit()
	await get_tree().process_frame
	return
	

func clear_graph():
	pass
