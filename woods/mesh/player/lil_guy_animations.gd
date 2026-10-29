extends Node3D
class_name LilGuyAnimations

var doAnimate: bool = true
var _isHolding: bool = false
var _oldIsHolding: bool = false
var _isWalking: bool = true
var isOnGround: bool = false

var Rarm: BoneAttachment3D
var Larm: BoneAttachment3D
var Rleg: BoneAttachment3D
var Lleg: BoneAttachment3D
var torso: BoneAttachment3D

var TIME_BT_STEPS: float = 0.15
var stepTimer: float = 0
var stepNum: int = 0
var STEP_Y_OFFSET: float = 1/8

var BASE_TORSO_Y: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rarm = $Rarm
	Larm = $Larm
	Rleg = $Rleg
	Lleg = $Lleg
	torso = $torso
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not doAnimate:
		return
	
	if _isWalking and isOnGround:
		if stepTimer > 0:
			stepTimer -= delta
		else:
			set_step(stepNum == 0)
			stepTimer = TIME_BT_STEPS
	else:
		set_step(false)
	pass
	_oldIsHolding = _isHolding

func set_is_holding(hold:bool):
	if _isHolding == hold:
		return
	_isHolding = hold
	if hold:
		Rarm.override_pose = true
		Larm.override_pose = true
		Rarm.rotate_z(-PI)
		Larm.rotate_z(PI)
		pass
	else:
		Rarm.override_pose = false
		Larm.override_pose = false
		pass
	pass

func set_step(legsUp: bool):
	if legsUp and isOnGround:
		Rleg.override_pose = true
		Lleg.override_pose = true
		Rleg.rotate_z(-PI/2)
		Lleg.rotate_z(PI/2)
		Rleg.position.y = 0.312
		Lleg.position.y = 0.312
		stepNum = 1
		torso.position.y = BASE_TORSO_Y + STEP_Y_OFFSET
		pass
	else:
		Rleg.override_pose = false
		Lleg.override_pose = false
		stepNum = 0
		torso.position.y = BASE_TORSO_Y
		pass
	pass

func set_is_walking(value: bool):
	if _isWalking == value:
		return
	_isWalking = value
	if value:
		set_step(true)
	pass
