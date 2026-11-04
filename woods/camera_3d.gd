extends Camera3D
class_name GameCamera

enum Mode {
	TITLE,
	GAME
}

var TITLE_POS: Vector3 = Vector3(5.75, 37, 17.0)
var GAME_POS: Vector3 = Vector3(5.75, 4.5, 17.0)

var PAN_LERP: float = 25
var PAN_MIN_DIST: float = 0.05
var targetPos: Vector3
var isPanning: bool = false

var mode: Mode

signal cam_did_pan(mode: Mode)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = TITLE_POS
	GameManager.i.begin_round_started.connect(begin_round_started)
	
	if GameManager.i.isDebug:
		PAN_LERP = 100
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isPanning:
		if targetPos.distance_to(position) < PAN_MIN_DIST:
			position = targetPos
			pan_finished()
			isPanning = false
		else:
			position = position.move_toward(targetPos, PAN_LERP * delta)
	pass

func begin_round_started():
	set_mode(Mode.GAME)
	pass

func pan_finished():
	cam_did_pan.emit(mode)
	pass

func set_mode(newMode: Mode):
	mode = newMode
	match mode:
		Mode.TITLE:
			pan_cam(TITLE_POS)
			pass
		Mode.GAME:
			pan_cam(GAME_POS)
			pass
	pass

func pan_cam(newTarget: Vector3):
	isPanning = true
	targetPos = newTarget
	pass
