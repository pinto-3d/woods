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

var camera: GameCamera
var titleScreen: TitleScreen
var loseScreen: LoseScreen

var player: Player

var isDebug: bool = true
var showDebugGrid: bool = false
signal begin_round_started();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.i != self:
		return
	LevelManager.i.lost.connect(lost)
	
	camera = ((Engine.get_main_loop() as SceneTree).root as Node).get_child(0).get_node("Camera3D")
	camera.cam_did_pan.connect(start_round)
	
	titleScreen = ((Engine.get_main_loop() as SceneTree).root as Node).get_child(0).get_node("TitleScreen")
	titleScreen.startPressed.connect(start_cam_panning_for_round_start)
	
	loseScreen = ((Engine.get_main_loop() as SceneTree).root as Node).get_child(0).get_node("LoseScreen")
	loseScreen.retryPressed.connect(retry)
	
	player = ((Engine.get_main_loop() as SceneTree).root as Node).get_child(0).get_node("Player")
	player.state = Entity.State.DISABLE_COMPLETELY
	player.global_position = Vector3(8,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_cam_panning_for_round_start():
	begin_round_started.emit()
	pass

func start_round(mode: GameCamera.Mode = GameCamera.Mode.GAME):
	RoundManager.i.start_new_round()
	LevelManager.i.start_new_level()
	player.state = Entity.State.FREE
	player.global_position = Vector3(8,0,0)
	player.start()
	pass

func lost():
	player.state = Entity.State.DISABLE_COMPLETELY
	loseScreen.lost()
	pass

func retry():
	start_round()
	loseScreen.visible = false
	pass
