extends Entity
class_name Character

const ACCELERATION = 160
const DECCELERATION = 80
const DECCELERATION_CROUCH = 40
const MAX_SPEED = 80.0
const MAX_CROUCH_SPEED = 20.0
const JUMP_VELOCITY = 160.0
const WALL_JUMP_VELOCITY: Vector2 = Vector2(120, 160)

const SPEED_LIMIT: float = 300

const CROUCH_BODY_Y: float = 100
const CROUCH_BODY_ANGLE: float = -50
const CROUCH_HEAD_Y: float = 80
const CROUCH_LEGS_Y: float = 1
const SLIDE_SLANT_ACCEL: float = 250
const SLIDE_SLANT_DECCEL: float = 100

const CROUCH_LAND_BOOST: float = 120
const CROUCH_SPEED: float = 300
const CROUCH_LERP: float = 30
const SLIDE_MIN_SPEED: float = 40
var crouchDetect: Area3D
const MIN_SLIDE_BOOST_SPEED = 200

const COL_STAND_HEIGHT: float = 13.5
const COL_CROUCH_HEIGHT: float = 9
const COL_RADIUS: float = 8

const INPUT_DEADZONE: float = 0.25

var inputVector: Vector2
var isDucking: bool
var isDuckingSlide: bool
var isOnSlant: bool
var canUnDuck: bool

var direction: int = 1
var invulnerable: bool = false
var health: int = 1

@export var publicVelocity: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	super._process(delta)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	pass

@warning_ignore("unused_parameter")
func get_hit(damage: float, knockback: float):
	if invulnerable:
		return
	@warning_ignore("narrowing_conversion")
	health -= damage
	if health <= 0:
		die()
	pass

func get_inputVector():
	inputVector.x = Input.get_axis("left", "right")
	inputVector.y = Input.get_axis("up", "down")
	return inputVector

func wall_jump(dir: int):
	if velocity.y < -MIN_SLIDE_BOOST_SPEED:
		velocity.y = velocity.y
	else:
		velocity.y = WALL_JUMP_VELOCITY.y
	velocity.x = dir * WALL_JUMP_VELOCITY.x
	
	pass


func die():
	pass
