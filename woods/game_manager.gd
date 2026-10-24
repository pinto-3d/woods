extends Node3D
class_name GameManager

static var i: GameManager

func _init() -> void:
	if GameManager.i:
		return
	GameManager.i = self
	pass

var isDebug: bool = true
var showDebugGrid: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.i != self:
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
