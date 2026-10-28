extends Node3D
class_name GameManager

static var i: GameManager:
	get:
		if _i:
			return _i
		_i = ((Engine.get_main_loop() as SceneTree).root as Node).get_child(0).get_node("GameManager")
		return _i
static var _i:GameManager

func _init() -> void:
	pass

var isDebug: bool = false
var showDebugGrid: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.i != self:
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
