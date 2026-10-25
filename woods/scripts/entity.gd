extends CharacterBody3D
class_name Entity

static var BasicBoxCollisionShape: BoxShape3D = load("res://basic_box_collision_shape.tres")

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
var LINEAR_GRAVITY_MAX: float = 3
const MIN_VELOCITY: float = 0.01

var THROW_VELOCITY: Vector2 = Vector2(3, 6)
var THROW_Y_BOOST: float = 6
var POST_THROW_PREVENT_PICKUP_TIME: float = 0.25
var postThrowPreventPickupTimer: float = 0

var armature: Node3D
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

var isRegisteredToGrid: bool = false
signal entityGridUpdate(entity: Entity, pos: Vector2)

signal clicked(entity: Entity)
var log: Log

func _init() -> void:
	pass

func _ready() -> void:
	col = get_node_or_null("CollisionShape3D")
	mesh = get_node_or_null("MeshInstance3D")
	armature = get_node_or_null("Armature")
	if mesh:
		if GameManager.i.isDebug:
			mesh.scale = Vector3.ONE * 0.8
			pass
	
	holdPoint = get_node_or_null("HoldPoint")
	if holdPoint:
		holdPoint.position.y = HOLD_POINT_Y_OFFSET
		
		if not GameManager.i.isDebug:
			var holdPointVisual = holdPoint.get_node_or_null("MeshInstance3D")
			if holdPointVisual:
				holdPointVisual.queue_free()
	if self is Player:
		pass
	if self is not ImmovableBlock:
		if GameManager.i.showDebugGrid:
			debugGridPosition = await NodeSpawner.spawn(debugCubeScene, get_tree())
			debugGridPosition.reparent(self, false)
			debugGridPosition.position = position
		pass
		
	debugLabel3d = get_node_or_null("DebugLabel3D")
	if not GameManager.i.isDebug:
		if debugLabel3d:
			debugLabel3d.queue_free()
	log = Log.new(self)
	pass

func add_log_entry(interactionType: LogEntry.InteractionType, interaction: String, thatEntity):
	log.add_entry(interactionType, interaction, self, thatEntity)
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
	global_position.z = 0

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
	
	if isHeld:
		pass
	else:
		_set_is_on_ground()
		prevNormal = info.normal
		if info.normal.y > 0:
			if self is not Character:
				if info.entity is Entity:
					if info.entity is ImmovableBlock:
						if is_above_entity(info.entity):
							GridManager.i.snap_entity_to_grid(self)
							self.velocity = Vector3.ZERO
							#add_log_entry(LogEntry.InteractionType.Collision, 
								#"snapped to grid above immovable block", info.entity)
					else:
						var highest = (info.entity as Entity).get_highest_held_entity()
						if not highest.isHolding:
							if is_above_entity(highest):
								highest.pickup(self)
								self.velocity = Vector3.ZERO
								add_log_entry(LogEntry.InteractionType.Collision, 
									"was picked up", info.entity)
							else:
								self.velocity = Vector3.ZERO
								info.entity.velocity = Vector3.ZERO
								GridManager.i.snap_entity_to_grid(self)
								GridManager.i.snap_entity_to_grid(info.entity)
								add_log_entry(LogEntry.InteractionType.Collision, 
									"almost picked up but instead snapped to grid", info.entity)
		#if normal.x != 0:
			#if not isHeld:
				#velocity.y = 0
			#pass
	pass

func is_above_entity(entity: Entity):
	var selfgrid = GridManager.i.get_grid_pos_of_entity(self)
	var othergrid = null
	if not selfgrid:
		return false
	if entity.isRegisteredToGrid:
		othergrid = GridManager.i.get_grid_pos_of_entity(entity)
	else:
		othergrid = Vector2i(round(entity.global_position.x), round(entity.global_position.y))
		pass
	if selfgrid.x == othergrid.x:
		if selfgrid.y == othergrid.y+1 or selfgrid.y == othergrid.y:
			return true
	return false

func move(delta: float):
	var preCollisionVelocity: Vector3 = velocity
		
	var collided = move_and_slide()
	if collided:
		var collisionInfo: CollisionInfo = CollisionInfo.new()
		var collisionCount: int = 1
		for index in range(0, collisionCount):
			var collision = get_last_slide_collision()
			if not collision:
				return
			collisionInfo.collision = collision
			collisionInfo.normal = collision.get_normal()
			collisionInfo.position = collision.get_position()
			collisionInfo.count = index
			collisionInfo.travel = collision.get_travel()
			collisionInfo.entity = collision.get_collider()
			handle_collision(collisionInfo)
			pass
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
	col.disabled = true
func set_as_not_held():
	hasLinearGravity = false;
	col.disabled = false
	
	holder = null
	isHeld = false
	reparent(GridManager.i.root, true)
	
	#var v2 = GridManager.i.get_entity_round_global_pos(self)
	#global_position = Vector3(v2.x, v2.y, 0)
	pass

func get_highest_held_entity() -> Entity:
	var highestEntity: Entity = self
	while highestEntity.heldEntity:
		highestEntity = highestEntity.heldEntity
	return highestEntity

func get_lowest_held_entity() -> Entity:
	var lowestEntity: Entity = self
	while lowestEntity.holder:
		lowestEntity = lowestEntity.holder
	return lowestEntity


func set_is_holding(entity: Entity):
	if entity.isHeld:
		entity.holder.set_is_not_holding()
		entity.set_as_not_held()
	
	heldEntity = entity
	add_collision_exception_with(heldEntity)
	heldEntity.position = Vector3.ZERO
	heldEntity.set_as_held(self)
	heldEntity.reparent(holdPoint, false)
	
	isHolding = true
	
	update_collider()
	pass

func update_collider():
	var highest: Entity = get_highest_held_entity()
	var lowest: Entity = get_lowest_held_entity()
	var colShape = BasicBoxCollisionShape.duplicate()
	if highest.name == lowest.name:
		lowest.col.shape = colShape
		lowest.col.position.y = 0
		add_log_entry(LogEntry.InteractionType.ColliderUpdate, "collider set to single", self)
		return
	var diff = highest.global_position.y - lowest.global_position.y
	var colSize = (highest.col.shape as BoxShape3D).size.y
	var totalSize = colSize + diff
	colShape.size.y = totalSize
	lowest.col.shape = colShape
	lowest.col.position.y = diff/2
	add_log_entry(LogEntry.InteractionType.ColliderUpdate, str("collider set to size ",totalSize), self)
	pass
	
func set_is_not_holding():
	remove_collision_exception_with(heldEntity)
	heldEntity = null
	isHolding = false
	update_collider()
	pass

func put_down(velocity: Vector2):
	if heldEntity:
		heldEntity.set_as_not_held()
		heldEntity.velocity = Vector3(velocity.x, velocity.y, 0)
	set_is_not_holding()
	pass
	
	
func throw(dir: Vector2):
	isHolding = false
	if heldEntity:
		dir.x *= THROW_VELOCITY.x
		if dir.y != 0:
			dir.y *= -THROW_VELOCITY.y
			if dir.y > 0:
				dir.y = -THROW_Y_BOOST * 2
			pass
		else:
			dir.y = THROW_VELOCITY.y
		var highestHolder: Entity = get_highest_held_entity()
		var highestPos: Vector3 = highestHolder.holdPoint.global_position
		put_down(dir)
		if dir.y < 0:
			self.global_position = highestPos
			self.velocity.y = THROW_Y_BOOST
			pass
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
	if isHeld:
		holder.set_is_not_holding()
		set_as_not_held()
	if isHolding:
		heldEntity.set_as_not_held()
		set_is_not_holding()
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



func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				clicked.emit(self)
			pass
		pass
	pass
	
func _on_mouse_entered() -> void:
	if not GameManager.i.isDebug:
		return
	pass # Replace with function body.
