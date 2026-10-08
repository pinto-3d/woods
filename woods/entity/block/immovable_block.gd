extends Block
class_name ImmovableBlock

func _init() -> void:
	super._init()

func _ready() -> void:
	isAffectedByGravity = false;
	isMovable = false;
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
