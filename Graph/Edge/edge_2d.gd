class_name Edge2D extends Edge

const COLLISION_SHAPE_THICKNESS : float = 10.0
const VISUAL_LINE_THICKNESS : float = 4.0
const LINE_CAP_MODE : Line2D.LineCapMode = Line2D.LINE_CAP_ROUND

@export var clickable_area : Area2D
@export var line : Line2D
@export var center_marker : Marker2D

func _ready() -> void:
	# if the node is entering the tree during actual game runtime (NOT when spawned by a tool script), connect this signal
	if !Engine.is_editor_hint():
		clickable_area.connect("input_event", _on_input_event)

## this function is needed to actually initialize the node bc if the data is set up in the editor while
## the game isn't running the scene and then saved to the scene with the data set, the game will instance the node & look
## for init variables if _init has possible parameters (even if the params are optional)
func with_data(vertex1 : Vertex, vertex2 : Vertex, edge_weight : float, id : String):
	super(vertex1, vertex2, edge_weight, id)
	draw_connection()
	return self

## Draws the connection between two vertices located in 2D space and connects [br]
## the Area2D to a [InteractionHandler]
func draw_connection() -> void:
	if vertices.is_empty() || weight == null:
		printerr(self, "Edge was constructed without necessary data. Ensure you're using Edge2D.new().with_data(...) to construct this ndoe.")
		return
	await ready
	var start : Node2D = null
	var end : Node2D = null
	var offset : Vector2
	var clickable_poly_points : PackedVector2Array
	var collision_polygon : CollisionPolygon2D
	
	
	for vertex in vertices:
		# grab a start position first, then grab the end position
		if start == null:
			start = vertex.get_actual_node()
		else:
			end = vertex.get_actual_node()
	
	
	#region setting up clickable area
	clickable_area = Area2D.new()
	collision_polygon = CollisionPolygon2D.new()
	add_child(clickable_area)
	clickable_area.add_child(collision_polygon)
	collision_polygon.owner = get_tree().edited_scene_root
	clickable_area.owner = get_tree().edited_scene_root
	
	# transforming start and end polygons to global space
	var global_start_poly : PackedVector2Array = transform_to_global_basis(start.padding.polygon, start.global_position)
	var global_end_poly : PackedVector2Array = transform_to_global_basis(end.padding.polygon, end.global_position)
	
	var shortest_line : PackedVector2Array = find_shortest_line(global_start_poly, global_end_poly)
	
	# generates a small, angled vector pointing from the start to the end that's 1/2 the clickable area's desired thickness
	offset = shortest_line[0].direction_to(shortest_line[1]).normalized() * COLLISION_SHAPE_THICKNESS
	
	# to generate 4 corners of connection poly
	clickable_poly_points.append(shortest_line[0] + offset.rotated(-90))
	clickable_poly_points.append(shortest_line[0] + offset.rotated(90))
	clickable_poly_points.append(shortest_line[1] + offset.rotated(90))
	clickable_poly_points.append(shortest_line[1] + offset.rotated(-90))
	
	if "padding" not in start || "padding" not in end:
		printerr(self, ": Endpoint node does not have property 'padding'. Skipping padding clipping")
		collision_polygon.set_polygon(clickable_poly_points)
		clickable_area.input_event.connect(_on_input_event, CONNECT_DEFERRED)
		return
	
	# clipping start & end polygons against connection polygon so no overlap exists
	clickable_poly_points = Geometry2D.clip_polygons(clickable_poly_points, global_start_poly)[0]
	clickable_poly_points = Geometry2D.clip_polygons(clickable_poly_points, global_end_poly)[0]
	
	collision_polygon.set_polygon(clickable_poly_points)
	
	#endregion
	
	center_marker = Marker2D.new()
	add_child(center_marker)
	center_marker.owner = get_tree().edited_scene_root
	center_marker.global_position = (shortest_line[0] + shortest_line[1]) / 2
	
	# drawing visual line between start & end
	line = Line2D.new()
	line.z_index = -1
	add_child(line)
	line.add_point(shortest_line[0])
	line.add_point(shortest_line[1])
	line.width = VISUAL_LINE_THICKNESS
	line.end_cap_mode = LINE_CAP_MODE
	line.begin_cap_mode = LINE_CAP_MODE
	line.owner = get_tree().edited_scene_root
	

func find_shortest_line(start : PackedVector2Array, end : PackedVector2Array) -> PackedVector2Array:
	if vertices.is_empty() || weight == null:
		printerr(self, "Edge was constructed without necessary data. Ensure you're using Edge2D.new().with_data(...) to construct this ndoe.")
		return []
	# initial shortest line should be AS LONG AS IT CAN BE so as soon as we compare it to a line which exists between the two nodes, it gets overidden
	var shortest : PackedVector2Array
	shortest.append(Vector2(INF, INF))
	shortest.append(Vector2(-INF, -INF))
	
	for start_vector in start:
		for end_vector in end:
			if start_vector.distance_to(end_vector) < shortest[0].distance_to(shortest[1]):
				shortest.clear()
				shortest.append(start_vector)
				shortest.append(end_vector)
	
	return shortest

func transform_to_global_basis(poly : PackedVector2Array, parent_global_transform : Vector2) -> PackedVector2Array:
	var global_basis_poly : PackedVector2Array
	for vector2 in poly:
		# do NOT ask me why the transform2d has to be flipped on both axis
		global_basis_poly.append(parent_global_transform + vector2)
	return global_basis_poly

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: 
	pass

func toggle_enable_state():
	if disabled:
		disabled = false
	else:
		disabled = true
	
	match_enable_state()

func match_enable_state():
	if line == null:
		printerr(self, ": Unable to update null Line2D")
		return
	
	if disabled:
		line.modulate = Color(0.231, 0.231, 0.225, 1.0)
	else:
		line.modulate = Color.WHITE
