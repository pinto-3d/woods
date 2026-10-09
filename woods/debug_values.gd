extends Panel

var label:Label
@export var dictDebugValues: Dictionary[String, String] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = $Label
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = ""
	for key in dictDebugValues:
		var variables = dictDebugValues[key].split(".")
		var test = get_tree().root
		var current_value = get_tree().root.get_child(0).get_node(variables[0])
		variables.remove_at(0)
		if variables[1] == "i":
			current_value += get_node(variables[0]+"."+variables[1])
			variables.remove_at(0)
			pass
		
		for variable in variables:
			if current_value is Dictionary:
				if not current_value.has(variable):
					break
				current_value = current_value[variable]
			elif current_value is Array:
				if not variable.is_valid_int():
					break
				var index := int(variable)
				if index < 0 or index >= current_value.size():
					break
				
				current_value = current_value[index]
			elif current_value is Object:
				if not variable in current_value:
					break
				current_value = current_value.get(variable)
			else:
				break
			pass
		
		
		label.text += key + ": " + str(current_value) + "\n"
		
		pass
	pass
