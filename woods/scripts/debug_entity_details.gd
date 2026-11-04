extends Control
class_name DebugEntityDetails

var lblName: Label
var lblDesc: Label

var target: Entity

var eraseButton: Button

func _ready() -> void:
	if not GameManager.i.isDebug:
		queue_free()
	lblName = $VBoxContainer/EntityName
	lblDesc = $VBoxContainer/EntityDesc
	eraseButton = $VBoxContainer/EraseButton
	eraseButton.visible = false
	GridManager.i.entity_registed.connect(register_entity)

func _process(delta: float) -> void:
	if target:
		update_details(target)
	else:
		eraseButton.visible = false
	pass

func register_entity(entity: Entity):
	if not entity.clicked.is_connected(set_target):
		entity.clicked.connect(set_target)
	pass

func set_target(entity: Entity):
	target = entity
	eraseButton.visible = true

func update_details(entity: Entity):
	lblName.text = entity.name
	lblDesc.text = ""
	if entity:
		if entity.log:
			lblDesc.text += entity.log.to_string()
		
	pass

func _on_clear_button_pressed() -> void:
	if target:
		target.erase()
		
	pass # Replace with function body.
