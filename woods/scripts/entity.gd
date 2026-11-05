extends CharacterBody3D
class_name Entity

static var BasicBoxCollisionShape: BoxShape3D = load("res://basic_box_collision_shape.tres")

enum State { FREE=0, DISABLE_INPUT=1, SPAWNING=2, DYING=3, DISABLE_COMPLETELY=4, DISABLE_PHYSICS = 5 }
enum RelativeDirection {
	LEFT = -1,
	FRONT = 0,
	RIGHT = 1
}

var state: State = State.FREE

var MIN_SLIDE_BOOST_SPEED = 200
var GRAVITY: float = 10.0;
var GRAVITY_DIRECTION: Vector3 = Vector3.DOWN;
var hasLinearGravity: bool = true
var LINEAR_GRAVITY_MAX: float = 3
var current_linear_gravity_max: float = 3
var FAST_FALL_MULTIPLIER: float = 4
const MIN_VELOCITY: float = 0.01

var THROW_VELOCITY: Vector2 = Vector2(3, 6)
var THROW_Y_BOOST: float = 4
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
var isHeld: bool:
	get:
		return holder != null
var isHolding: bool:
	get:
		return heldEntity != null
var holder: Entity
var holdPoint: Node3D
var HOLD_POINT_Y_OFFSET: float = 1
var heldEntity: Entity

var debugCubeScene: PackedScene = load("res://debug_cube.tscn")
var debugGridPosition: MeshInstance3D

var debugLabel3d: Label3D

const MAX_COLLISIONS = 6

var direction: RelativeDirection = RelativeDirection.FRONT

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

var downTimer: float = 0
var DOWN_PRESS_PRE_FAST_FALL: float = 0.5

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
				if Input.is_action_pressed("down"):
					if downTimer > 0:
						downTimer -= delta
					else:
						current_linear_gravity_max = LINEAR_GRAVITY_MAX * FAST_FALL_MULTIPLIER
					pass
				else:
					downTimer = DOWN_PRESS_PRE_FAST_FALL
					current_linear_gravity_max = LINEAR_GRAVITY_MAX
				if velocity.y < -current_linear_gravity_max:
					velocity.y = -current_linear_gravity_max
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
		if info.normal.y > 0.25:
			if self is not Character:
				if info.entity is Entity:
					if info.entity is ImmovableBlock:
						GridManager.i.snap_entity_to_grid(self)
						isMovable = false
						self.velocity = Vector3.ZERO
						#if is_above_entity(info.entity):
							#add_log_entry(LogEntry.InteractionType.Collision, 
								#"snapped to grid above immovable block", info.entity)
					else:
						var highest = (info.entity as Entity).get_highest_held_entity().entity
						if not highest.isHolding:
							#var selfpos = self.global_position
							#selfpos = GridManager.i.snap_entity_to_grid(self)
							highest.pickup(self)
							self.velocity = Vector3.ZERO
							add_log_entry(LogEntry.InteractionType.Collision, 
								"was picked up", info.entity)
							if is_above_entity(highest):
								pass
							else:
								pass
								#self.velocity = Vector3.ZERO
								#info.entity.velocity = Vector3.ZERO
								#var presnap_selfpos = self.global_position
								#var presnap_otherpos = info.entity.global_position
								#
								#selfpos = GridManager.i.snap_entity_to_grid(self)
								#var otherpos = GridManager.i.snap_entity_to_grid(info.entity)
								#if selfpos == otherpos:
									#add_log_entry(LogEntry.InteractionType.Collision, 
										#"almost picked up but instead snapped to grid. pos was the same after snap", info.entity)
									#pass
								#else:
									#add_log_entry(LogEntry.InteractionType.Collision, 
										#str("almost picked up but instead snapped to grid. \n.\tnormal:", info.normal,"\n.\tselfpos:",presnap_selfpos,"\n.\totherpos:",presnap_otherpos), info.entity)
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
	if othergrid:
		if selfgrid.x == othergrid.x:
			if selfgrid.y == othergrid.y+1 or selfgrid.y == othergrid.y:
				return true
	return false

func move(delta: float):
	var preCollisionVelocity: Vector3 = velocity
	if isMovable:
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
			#if isOnGround:
				#if self is Block and true:
					#if global_position.x != round(global_position.x):
						#GridManager.i.snap_entity_to_grid(self)
						#pass
			pass
	
	if not isHeld:
		if abs(velocity.x) < MIN_SPEED and velocity.y == 0:
			if isOnGround:
				if abs(round(global_position.x) - global_position.x) < ROUND_DIST:
					GridManager.i.snap_entity_to_grid(self)
	
	if isOnGroundOld and not isOnGround:
		pass
	isOnGroundOld = isOnGround

var MIN_SPEED: float = 0.1
var ROUND_DIST: float = 0.05

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
	
	if isHolding:
		update_collider()
	
	#var v2 = GridManager.i.get_entity_round_global_pos(self)
	#global_position = Vector3(v2.x, v2.y, 0)
	pass

func get_highest_held_entity():
	var highestEntity: Entity = self
	var count: int = 1
	while highestEntity.heldEntity:
		highestEntity = highestEntity.heldEntity
		count += 1
	return {
		"entity": highestEntity,
		"count": count
		}

func get_lowest_held_entity() -> Entity:
	var lowestEntity: Entity = self
	while lowestEntity.holder:
		lowestEntity = lowestEntity.holder
	return lowestEntity


func set_is_holding(entity: Entity, onlyThisOne: bool = false) -> bool:
	if entity.isHeld:
		entity.holder.set_is_not_holding()
		entity.set_as_not_held()
	
	var otherHighest = entity
	
	if not onlyThisOne:
		otherHighest = entity.get_highest_held_entity().entity
	var selfHighest = get_highest_held_entity().entity
	var otherHighestGrid = GridManager.i.get_grid_pos_of_entity(otherHighest)
	var baseEntityGrid = GridManager.i.get_grid_pos_of_entity(entity)
	if not otherHighestGrid:
		return false
	if not baseEntityGrid:
		return false
	
	var diff = otherHighestGrid.y - baseEntityGrid.y
	var selfGrid = GridManager.i.get_grid_pos_of_entity(self)
	if not selfGrid:
		return false
	var newHighestGrid = selfGrid.y + diff
	if newHighestGrid >= LevelManager.i.BLOCK_SPAWN_Y:
		return false
	
	if baseEntityGrid.x != selfGrid.x:
		var currentY: int = selfGrid.y + 1
		while currentY < newHighestGrid:
			if GridManager.i.get_entity_at_grid_pos(Vector2i(selfGrid.x, currentY)):
				return false
			currentY += 1
	
	if onlyThisOne:
		if entity.heldEntity:
			entity.heldEntity.set_as_not_held()
			entity.set_is_not_holding()
	
	selfHighest.heldEntity = entity
	selfHighest.add_collision_exception_with(heldEntity)
	selfHighest.heldEntity.position = Vector3.ZERO
	selfHighest.heldEntity.set_as_held(self)
	selfHighest.heldEntity.reparent(holdPoint, false)
	selfHighest.isHolding = true
	
	var lowest = get_lowest_held_entity()
	lowest.update_collider()
	if self is ImmovableBlock:
		entity.isMovable = false
	else:
		entity.isMovable = true
	
	return true
	pass

func update_collider():
	var highestVar = get_highest_held_entity()
	var highest: Entity = highestVar.entity
	var highCount: int = highestVar.count
	var lowest: Entity = get_lowest_held_entity()
	var colShape = BasicBoxCollisionShape.duplicate()
	if highest == lowest:
		lowest.col.shape = colShape
		lowest.col.position.y = 0
		add_log_entry(LogEntry.InteractionType.ColliderUpdate, "collider set to single", self)
		return
	var highestGridPos = GridManager.i.get_grid_pos_of_entity(highest)
	var lowestGridPos = GridManager.i.get_grid_pos_of_entity(lowest)
	var diff = highCount
	var colSize = (highest.col.shape as BoxShape3D).size.y
	var totalSize = diff
	colShape.size.y = totalSize
	lowest.col.shape = colShape
	var halfDiff: float = (diff - 1)/2.0
	lowest.col.position.y = halfDiff
	add_log_entry(LogEntry.InteractionType.ColliderUpdate, str("collider set to size ",halfDiff), self)
	pass
	
func set_is_not_holding():
	remove_collision_exception_with(heldEntity)
	heldEntity = null
	isHolding = false
	var lowest = get_lowest_held_entity()
	lowest.update_collider()
	pass

func put_down(pos: Vector2, velocity: Vector2) -> bool:
	if heldEntity:
		if pos.x < LevelManager.i.topLeft.x or pos.x >= LevelManager.i.topRight.x:
			return false
			pass
		
		GridManager.i.snap_entity_to_grid_pos(heldEntity, pos)
		if heldEntity:
			heldEntity.set_as_not_held()
			heldEntity.velocity = Vector3(velocity.x, velocity.y, 0)
	set_is_not_holding()
	return true
	
	
func throw(dir: Vector2):
	isHolding = false
	if heldEntity:
		dir *= THROW_VELOCITY
		if dir.y != 0:
			pass
		else:
			dir.y = THROW_VELOCITY.y
		var highestHolder: Entity = get_highest_held_entity().entity
		var highestPos: Vector3 = highestHolder.holdPoint.global_position
		if dir.y < 0:
			if highestPos.y >= LevelManager.i.BLOCK_SPAWN_Y:
				return
			if GridManager.i.get_entity_at_grid_pos(GridManager.i.position_to_grid(highestPos)):
				return
			pass
		
		var putDownPos = GridManager.i.position_to_grid(heldEntity.global_position)
		put_down(putDownPos, dir)
		if dir.y < 0:
			highestPos.y -= 0
			self.global_position = highestPos
			if not isOnGround:
				self.velocity.y = THROW_Y_BOOST
			pass
		postThrowPreventPickupTimer = POST_THROW_PREVENT_PICKUP_TIME

func place(dir: Vector2i):
	isHolding = false
	if heldEntity:
		put_down(dir, Vector2.ZERO)
	pass

func pickup(entity: Entity):
	if not holdPoint:
		return
	if postThrowPreventPickupTimer > 0:
		return
	
	if set_is_holding(entity):
		print("pickup")
	else:
		print("failed pickup")
	pass

func pickup_single(entity: Entity):
	if not holdPoint:
		return
	if postThrowPreventPickupTimer > 0:
		return
	
	if set_is_holding(entity, true):
		print("pickup")
	else:
		print("failed pickup")
	pass

func erase():
	if isHeld:
		holder.set_is_not_holding()
		set_as_not_held()
	if isHolding:
		if heldEntity:
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
