@tool
class_name CustomPropertyNode extends Node

# NOTE: This doesn't do anything yet
var conditional_option : bool = true


@export_category("Example Export Category")
@export var node : Node:
	set(value):
		node = value
		notify_property_list_changed()
		update_configuration_warnings()

@export_file var file : Array[String]


func _get_property_list() -> Array[Dictionary]:
	var property_list : Array[Dictionary] = []
	
	if node != null:
		property_list.append({
			"name": "Options/Conditional Option",
			"type": TYPE_BOOL,
		})
	
	return property_list


func _set(property: StringName, value: Variant) -> bool:
	var should_property_be_visible : bool = true
	
	match property:
		"Options/Conditional Option":
			conditional_option = value
			notify_property_list_changed()
		_:
			should_property_be_visible = false
	
	return should_property_be_visible


func _get(property: StringName) -> Variant:
	match property:
		"Options/Conditional Option":
			return conditional_option
	
	return null
#endregion


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	
	if node == null:
		warnings.append("Please set a node!")
	
	return warnings
