extends Control
class_name DebugEntityDetails

var lblName: Label
var lblDesc: Label

var target: Entity

func _ready() -> void:
	if not GameManager.i.isDebug:
		queue_free()
	lblName = $VBoxContainer/EntityName
	lblDesc = $VBoxContainer/EntityDesc
	GridManager.i.entity_registed.connect(register_entity)

func _process(delta: float) -> void:
	if target:
		update_details(target)
	pass

func register_entity(entity: Entity):
	entity.clicked.connect(set_target)
	pass

func set_target(entity: Entity):
	target = entity

func update_details(entity: Entity):
	lblName.text = entity.name
	lblDesc.text = ""
	if entity.log:
		lblDesc.text += entity.log.to_string()
	pass
