extends Panel

var label:Label
@export var dictDebugValues: Dictionary[String, String] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = $Label
	pass # Replace with function body.


func _process(delta: float) -> void:
	label.text = ""

	for key in dictDebugValues:
		var variables = dictDebugValues[key].split(".")
		var current_value = get_tree().root.get_child(0).get_node(variables[0])
		variables.remove_at(0)

		for variable in variables:
			if variable.begins_with("get_child(") and variable.ends_with(")"):
				var index_str = variable.trim_prefix("get_child(").trim_suffix(")")
				
				if not index_str.is_valid_int():
					break

				var index = int(index_str)

				if current_value is Node:
					if index < 0 or index >= current_value.get_child_count():
						break
					current_value = current_value.get_child(index)
				else:
					break

			elif current_value is Dictionary:
				if not current_value.has(variable):
					break
				current_value = current_value[variable]

			elif current_value is Array:
				if not variable.is_valid_int():
					break

				var index = int(variable)

				if index < 0 or index >= current_value.size():
					break

				current_value = current_value[index]

			elif current_value is Object:
				if not variable in current_value:
					break
				current_value = current_value.get(variable)

			else:
				break

		label.text += key + ": " + str(current_value) + "\n"
