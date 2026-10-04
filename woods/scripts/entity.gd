extends CharacterBody3D
class_name Entity

enum State {FREE=0, DISABLE_INPUT=1, SPAWNING=2, DYING=3, DISABLE_COMPLETELY=4, DISABLE_PHYSICS = 5}

var state: State = State.DISABLE_COMPLETELY

var mesh: MeshInstance3D
var col: CollisionShape3D
var leftRay: Area3D
var rightRay: Area3D
var groundRays: Array[RayCast3D] = []

var isOnGround: bool
var isOnGroundOld: bool
var wallOnLeft: bool = false
var wallOnRight: bool = false

const MAX_COLLISIONS = 6

func _init() -> void:
	pass

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	isOnGround = false;
	for ray in groundRays:
		if ray.is_colliding():
			isOnGround = true
			break
		pass
	
	if leftRay.has_overlapping_bodies():
		wallOnLeft = true
	else:
		wallOnLeft = false
	if rightRay.has_overlapping_bodies():
		wallOnRight = true
	else:
		wallOnRight = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
