@tool
extends Block
class_name BasicBlock


func _init() -> void:
	super._init()

func _ready() -> void:
	isMovable = true
	isAffectedByGravity = true
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
