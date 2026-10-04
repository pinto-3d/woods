extends Entity
class_name Block

func _init() -> void:
	super._init()

func _ready() -> void:
	mesh = $MeshInstance3D
	col = $CollisionShape3D
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
