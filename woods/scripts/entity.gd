extends CharacterBody3D
class_name Entity

enum State {FREE=0, DISABLE_INPUT=1, SPAWNING=2, DYING=3, DISABLE_COMPLETELY=4, DISABLE_PHYSICS = 5}
enum RelativeDirection {
	LEFT = -1, 
	RIGHT = 1
}

var state: State = State.FREE

var MIN_SLIDE_BOOST_SPEED = 200
var GRAVITY: float = 10.0;
var GRAVITY_DIRECTION: Vector3 = Vector3.DOWN;
var hasLinearGravity: bool = true
var LINEAR_GRAVITY_MAX: float = 3;
const MIN_VELOCITY: float = 0.01

var THROW_VELOCITY: Vector2 = Vector2(10, 10)

var mesh: MeshInstance3D
var col: CollisionShape3D
var leftRay: RayCast3D
var rightRay: RayCast3D
var groundRays: Array[RayCast3D] = []

var isOnGround: bool
var isOnGroundOld: bool
var isOnSlant: bool
var wallOnLeft: bool = false
var wallOnRight: bool = false

var isAffectedByGravity: bool = true
var isMovable: bool = true;

var isHoldable: bool = true;
var isHeld: bool = false
var isHolding: bool = false
var holder: Entity
var holdPoint: Node3D
var HOLD_POINT_Y_OFFSET: float = 1
var heldEntity: Entity
var heldEntityPrevParent: Node

const MAX_COLLISIONS = 6

var direction: RelativeDirection = RelativeDirection.RIGHT

signal entityGridUpdate(entity: Entity, pos: Vector2)

func _init() -> void:
	pass

func _ready() -> void:
	holdPoint = get_node_or_null("HoldPoint")
	if holdPoint:
		holdPoint.position.y = HOLD_POINT_Y_OFFSET
	if self is Player:
		pass
	pass

func _process(delta: float) -> void:
	pass

func _set_is_on_ground():
	isOnGround = false;
	for ray in groundRays:
		if ray.is_colliding():
			isOnGround = true
			break
		pass
	pass

func _physics_process(delta: float) -> void:
	if isHeld:
		pass
	entityGridUpdate.emit(self, global_position)
	if not isMovable or isHeld:
		if self is not ImmovableBlock:
			pass
		velocity = Vector3.ZERO
		return
	_set_is_on_ground()
	
	if leftRay:
		if leftRay.is_colliding():
			wallOnLeft = true
		else:
			wallOnLeft = false
	if rightRay:
		if rightRay.is_colliding():
			wallOnRight = true
		else:
			wallOnRight = false
	
	if isAffectedByGravity:
		if not is_on_floor():
			velocity += GRAVITY_DIRECTION * GRAVITY * delta
			if hasLinearGravity:
				if velocity.y < -LINEAR_GRAVITY_MAX:
					velocity.y = -LINEAR_GRAVITY_MAX
					pass

	move(delta)

func _try_slant_boost(normal:Vector3, preCollisionVelocity: Vector3):
	pass

func jump():
	pass

func move(delta: float):
	var preCollisionVelocity: Vector3 = velocity
		
	var collided = move_and_slide()
	if collided:
		var collision = get_last_slide_collision()
		var normal = collision.get_normal()
		var pos = collision.get_position()
		var count = get_slide_collision_count()
		var travel = collision.get_travel()
		var entity = collision.get_collider()

		if count > 1:
			for i in range(0, count):
				#print(Time.get_ticks_msec())
				#print("   ",get_slide_collision(i).get_normal())
				#print("   ",get_slide_collision(i).get_position())
				
				if get_slide_collision(i).get_normal() == Vector3(0, -1, 0):
					pass
				pass
			pass
		
		_set_is_on_ground()
		prevNormal = normal
		if normal.y > 0:
			if self is not Character:
				if entity is Entity:
					if not entity.isHolding:
						entity.pickup(self)
					pass
			pass
		
		if normal.y < 0 and normal.y != -1:
			isOnSlant = true
			_try_slant_boost(normal, preCollisionVelocity)
	else:
		if isOnGround:
			var downNormal = get_down_normal()
			if downNormal:
				if downNormal.y < 0 and downNormal.y != -1:
					isOnSlant = true
				else:
					isOnSlant = false
			else:
				if isOnSlant:
					pass
				isOnSlant = false
				
				#slide_tick(delta, downNormals[chosen], preCollisionVelocity)
		else:
			isOnSlant = false
		
	if isOnGroundOld and not isOnGround:
		pass
	isOnGroundOld = isOnGround

var prevNormal = Vector3.ZERO

func set_as_held(entity: Entity):
	holder = entity
	isHeld = true
func was_thrown():
	holder = null
	isHeld = false
	pass
func throw(dir: Vector2):
	isHolding = false
	if heldEntity:
		heldEntity.was_thrown()
		heldEntity.reparent(heldEntityPrevParent, true)
		dir.x *= THROW_VELOCITY.x
		if dir.y < THROW_VELOCITY.y:
			dir.y = THROW_VELOCITY.y
			pass
		heldEntity.velocity = Vector3(dir.x, dir.y, 0);
		self.remove_collision_exception_with(heldEntity)
		heldEntity = null
		
	pass

func set_as_picked_up(entity:Entity):
	isHeld = true
	holder = entity
	pass

func pickup(entity: Entity):
	if not holdPoint:
		return
	var highestHolder:Entity = heldEntity
	if highestHolder:
		while highestHolder.heldEntity:
			highestHolder = highestHolder.heldEntity
	else:
		heldEntity = entity
		heldEntityPrevParent = heldEntity.get_parent()
		highestHolder = self
		
	heldEntity.reparent(highestHolder.holdPoint, false)
	highestHolder.add_collision_exception_with(heldEntity)
	
	heldEntity.position = Vector3.ZERO
	heldEntity.set_as_picked_up(self)
	isHolding = true
	
	print("pickup")
	pass

func get_down_normal() -> Variant:
	for ray in groundRays:
		if ray.is_colliding():
			return ray.get_collision_normal()
		pass
	return null

func iteracted_with(entity: Entity):
	pass
