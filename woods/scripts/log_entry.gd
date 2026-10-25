class_name LogEntry

enum InteractionType {
	Collision,
	ColliderUpdate
}

var time: float = -1
var interactionType: InteractionType
var interactionDescription: String = ""
var thisEntity = {}
var otherEntity = {}

func _init(interactionType: InteractionType, interaction: String, thisEntity, thatEntity):
	self.interactionType = interactionType
	self.interactionDescription = interaction
	self.thisEntity = thisEntity
	self.otherEntity = thatEntity
	self.time = Time.get_ticks_msec()

func _to_string() -> String:
	var str: String = ""
	str += str(time)+":"
	str += str(interactionType)
	if otherEntity:
		str += "\n    " + str(otherEntity.name)
	str += ":    " + str(interactionDescription)
	str += "\n"
	return str
