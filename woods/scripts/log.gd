class_name Log

var entries: Array[LogEntry] = []
var thisEntity

var isActive: bool = false

func _init(thisEntity) -> void:
	self.thisEntity = thisEntity
	
	pass

func add_entry(interactionType: LogEntry.InteractionType, interaction: String, thisEntity, thatEntity):
	var entry: LogEntry = LogEntry.new(interactionType, interaction, thisEntity, thatEntity)
	entries.append(entry)
	
	pass

func _to_string() -> String:
	var str = ""
	for entry in entries:
		str += entry.to_string()
		pass
	return str
