extends Entity
class_name Character

const ACCELERATION = 40
const DECCELERATION = 80
const DECCELERATION_CROUCH = 40
const MAX_SPEED = 4.0
const MAX_CROUCH_SPEED = 20.0
const JUMP_VELOCITY = 7.0
const WALL_JUMP_VELOCITY: Vector2 = Vector2(5, 5)

var wallJumpCount: int = 0
var WALL_JUMP_COUNT_MAX: int = 1;
var prevWallJumpSide: int = 0;
const WALL_JUMP_LAUNCH_TIME: float = 0.5
var launchTimer: float = 0.0

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

const COL_STAND_HEIGHT: float = 13.5
const COL_CROUCH_HEIGHT: float = 9
const COL_RADIUS: float = 8


const INPUT_DEADZONE: float = 0.25

var inputVector: Vector2
var isDucking: bool
var isDuckingSlide: bool
var canUnDuck: bool
var isLaunching: bool


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

func set_direction(dir: int):
	if dir == 0:
		pass
	direction = dir
	if dir == -1:
		pass
	elif dir == 1:
		pass
	else:
		return
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if isOnGround:
		wallJumpCount = WALL_JUMP_COUNT_MAX
		prevWallJumpSide = 0
	get_inputVector()
	match state:
		State.FREE:
			if isLaunching:
				launchTimer -= delta
				if launchTimer < 0:
					isLaunching = false
				if isOnGround:
					isLaunching = false
			if abs(inputVector.x) > INPUT_DEADZONE:
				@warning_ignore("unused_parameter", "narrowing_conversion")
				if inputVector.x > 0:
					set_direction(1)
				elif inputVector.x < 1:
					set_direction(-1)
			if abs(inputVector.x) > INPUT_DEADZONE:
				if isDucking:
					if not isDuckingSlide:
						velocity.x = move_toward(velocity.x, MAX_CROUCH_SPEED * direction, ACCELERATION * delta)
				else:
					if isOnGround:
						velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION * delta)
					else:
						if sign(velocity.x) != direction or abs(velocity.x) < abs(MAX_SPEED):
							if not isLaunching:
								velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION * delta)
			else:
				if isOnGround:
					velocity.x = move_toward(velocity.x, 0.0, DECCELERATION * delta)
			
			if velocity.length() > SPEED_LIMIT:
				velocity = velocity.normalized() * SPEED_LIMIT
				pass
			if velocity.x > SPEED_LIMIT:
				velocity.x = SPEED_LIMIT
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

func _try_slant_boost(normal:Vector3, preCollisionVelocity: Vector3):
	if abs(inputVector.y) > INPUT_DEADZONE:
		if not isOnGroundOld:
			if preCollisionVelocity.y < -MIN_SLIDE_BOOST_SPEED:
				if abs(normal.x) > PI/6 and abs(normal.x) < PI/3:
					if normal.x > 0:
						velocity.y = 0
						velocity.x = preCollisionVelocity.length()
						velocity = velocity.rotated(Vector3(0,0,1), PI/4)
						pass
					else:
						velocity.y = 0
						velocity.x = -preCollisionVelocity.length()
						velocity = velocity.rotated(Vector3(0,0,1), -PI/4)
						pass
					pass
	pass

func get_inputVector() -> Vector2:
	return Vector2.ZERO;

func _try_wall_jump(dir: int):
	if prevWallJumpSide != -dir:
		wall_jump(dir)
	pass

func wall_jump(dir: int):
	if velocity.y < -MIN_SLIDE_BOOST_SPEED:
		velocity.y = velocity.y
	else:
		velocity.y = WALL_JUMP_VELOCITY.y
	velocity.x = dir * WALL_JUMP_VELOCITY.x
	wallJumpCount -= 1
	prevWallJumpSide = -dir
	start_launch(WALL_JUMP_LAUNCH_TIME)
	pass

func start_launch(time: float):
	isLaunching = true
	launchTimer = time
	pass

func die():
	pass
