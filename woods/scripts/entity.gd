extends CharacterBody3D
class_name Entity

enum State { FREE=0, DISABLE_INPUT=1, SPAWNING=2, DYING=3, DISABLE_COMPLETELY=4, DISABLE_PHYSICS = 5 }
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

var THROW_VELOCITY: Vector2 = Vector2(3, 6)
var THROW_Y_BOOST: float = 8
var POST_THROW_PREVENT_PICKUP_TIME: float = 0.25
var postThrowPreventPickupTimer: float = 0

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

var debugCubeScene: PackedScene = load("res://debug_cube.tscn")
var debugGridPosition: MeshInstance3D

var debugLabel3d: Label3D

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
	if self is not ImmovableBlock:
		#debugGridPosition = await NodeSpawner.spawn(debugCubeScene, get_tree())
		#debugGridPosition.reparent(self, false)
		#debugGridPosition.position = position
		pass
		
	debugLabel3d = get_node_or_null("DebugLabel3D")
	pass

func _process(delta: float) -> void:
	if debugLabel3d:
		debugLabel3d.text = ""
		var v2 = GridManager.i.get_grid_pos_of_entity(self)
		if v2:
			debugLabel3d.text += str(v2) + "\n"
		if heldEntity:
			v2 = GridManager.i.get_grid_pos_of_entity(heldEntity)
			if v2:
				debugLabel3d.text += ".  "+str(v2) + "\n"
		else:
				debugLabel3d.text += ".  " + "\n"
		debugLabel3d.text += str(isHeld) + "\n"

func _set_is_on_ground():
	isOnGround = false;
	for ray in groundRays:
		ray.force_raycast_update()
		if ray.is_colliding():
			isOnGround = true
			break
		pass
	pass

func _physics_process(delta: float) -> void:
	if postThrowPreventPickupTimer > 0:
		postThrowPreventPickupTimer -= delta
		
	if isHeld:
		pass
	entityGridUpdate.emit(self, global_position)
	if debugGridPosition:
		if GridManager.i.dictEntity2Grid.has(self):
			debugGridPosition.global_position = GridManager.i.grid_to_position(GridManager.i.dictEntity2Grid[self])
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

class CollisionInfo:
	var collision: KinematicCollision3D
	var normal: Vector3
	var position: Vector3
	var count: int
	var travel: Vector3
	var entity: Node3D
	pass

func handle_collision(info: CollisionInfo):
	if info.count > 1:
		for i in range(0, info.count):
			#print(Time.get_ticks_msec())
			#print("   ",get_slide_collision(i).get_normal())
			#print("   ",get_slide_collision(i).get_position())
			
			if get_slide_collision(i).get_normal() == Vector3(0, -1, 0):
				pass
			pass
		pass
	
	if isHeld:
		pass
	else:
		_set_is_on_ground()
		prevNormal = info.normal
		if info.normal.y > 0:
			if self is not Character:
				if info.entity is Entity:
					if not info.entity.isHolding:
						
						info.entity.pickup(self)
					pass
			pass
		
		#if normal.x != 0:
			#if not isHeld:
				#velocity.y = 0
			#pass
	pass

func move(delta: float):
	var preCollisionVelocity: Vector3 = velocity
		
	var collided = move_and_slide()
	if collided:
		var collisionInfo: CollisionInfo = CollisionInfo.new()
		var collision = get_last_slide_collision()
		collisionInfo.collision = collision
		collisionInfo.normal = collision.get_normal()
		collisionInfo.position = collision.get_position()
		collisionInfo.count = get_slide_collision_count()
		collisionInfo.travel = collision.get_travel()
		collisionInfo.entity = collision.get_collider()
		handle_collision(collisionInfo)
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
func set_as_not_held():
	hasLinearGravity = false;
	
	holder = null
	isHeld = false
	reparent(GridManager.i.root, true)
	
	#var v2 = GridManager.i.get_entity_round_global_pos(self)
	#global_position = Vector3(v2.x, v2.y, 0)
	pass

func set_is_holding(entity: Entity):
	if entity.isHeld:
		entity.holder.set_is_not_holding()
		entity.set_as_not_held()
	
	heldEntity = entity
	heldEntity.reparent(holdPoint, false)
	add_collision_exception_with(heldEntity)
	
	heldEntity.position = Vector3.ZERO
	heldEntity.set_as_held(self)
	isHolding = true
	pass
func set_is_not_holding():
	remove_collision_exception_with(heldEntity)
	heldEntity = null
	isHolding = false
	pass
	
	
func throw(dir: Vector2):
	isHolding = false
	if heldEntity:
		heldEntity.set_as_not_held()
		
		dir.x *= THROW_VELOCITY.x
		if dir.y != 0:
			dir.y *= -THROW_VELOCITY.y
			if dir.y < 0:
				var highestHolder: Entity = heldEntity
				while highestHolder.heldEntity:
					highestHolder = highestHolder.heldEntity
				self.global_position = highestHolder.holdPoint.global_position
				heldEntity.velocity.y = -THROW_Y_BOOST
				self.velocity.y = THROW_Y_BOOST
			pass
		else:
			dir.y = THROW_VELOCITY.y
		heldEntity.velocity = Vector3(dir.x, dir.y, 0);
		set_is_not_holding()
		postThrowPreventPickupTimer = POST_THROW_PREVENT_PICKUP_TIME

func place(dir: Vector2i):
	isHolding = false
	if heldEntity:
		heldEntity.was_thrown()
		heldEntity.reparent(GridManager.i.root, true)
		var v2 = GridManager.i.get_entity_round_global_pos(heldEntity)
		heldEntity.global_position = Vector3(v2.x + dir.x, v2.y, 0)
		if dir.y != 0:
			dir.y *= -THROW_VELOCITY.y
			if dir.y < 0:
				var highestHolder: Entity = heldEntity
				while highestHolder.heldEntity:
					highestHolder = highestHolder.heldEntity
				self.global_position = highestHolder.holdPoint.global_position
			pass
		self.remove_collision_exception_with(heldEntity)
		heldEntity = null
	pass

func pickup(entity: Entity):
	if not holdPoint:
		return
	if postThrowPreventPickupTimer > 0:
		return
	
	set_is_holding(entity)
	
	print("pickup")
	pass

func erase():
	queue_free()
	pass

func get_down_normal() -> Variant:
	for ray in groundRays:
		if ray.is_colliding():
			return ray.get_collision_normal()
		pass
	return null

func iteracted_with(entity: Entity):
	pass
