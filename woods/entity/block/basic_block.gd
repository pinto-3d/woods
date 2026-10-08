extends Block
class_name BasicBlock


func _init() -> void:
	super._init()

func _ready() -> void:
	super._ready()
	TEX_SEED = global_position.x;
	BRIGHTNESS_MIN_MAX = Vector2(0, 1)
	TINT = Color.WHITE;
	RESOLUTION = 8;
	isMovable = true
	isAffectedByGravity = true

func _process(delta: float) -> void:
	super._process(delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
