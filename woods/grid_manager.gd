extends Node3D
class_name GridManager

static var i: GridManager


var root: Node3D

const BLOCK_SIZE: float = 1.0
const OFFSET: Vector2 = Vector2(0, 0)
const Z_OFFSET: float = 0

var dictGrid2Entity: Dictionary[Vector2i, Entity] = {}
var dictEntity2Grid: Dictionary[Entity, Vector2i] = {}
var entityList: Array[Entity] = []

func _init() -> void:
	if GridManager.i:
		return
	GridManager.i = self
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GridManager.i != self:
		return
	root = get_tree().root.get_child(0)

func _process(delta: float) -> void:
	if entityList.size() > 1:
		#print("grav: ",entityList[1].GRAVITY_DIRECTION * entityList[1].GRAVITY)
		#print("velo: ",entityList[1].velocity)
		#print("dot:  ",entityList[1].velocity.dot(entityList[1].GRAVITY_DIRECTION * entityList[1].LINEAR_GRAVITY_MAX))
		#print("dot2:  ",(entityList[1].GRAVITY_DIRECTION * entityList[1].LINEAR_GRAVITY_MAX).dot(entityList[1].velocity))
		pass
	pass

func clear():
	dictGrid2Entity.clear()
	dictEntity2Grid.clear()
	pass

func position_to_grid(pos) -> Vector2i:
	pos /= BLOCK_SIZE
	return Vector2(round(pos.x), round(pos.y)) + OFFSET
func grid_to_position(grid:Vector2) -> Vector3:
	grid *= BLOCK_SIZE
	grid += OFFSET
	return Vector3(grid.x, grid.y, Z_OFFSET)

func get_grid_pos_entity(pos: Vector2i):
	if dictGrid2Entity.has(pos):
		return dictGrid2Entity[pos]
	return null
func get_entity_grid_pos(entity: Entity):
	if dictEntity2Grid.has(entity):
		return dictEntity2Grid[entity]
	return null

func get_entity_round_global_pos(entity: Entity):
	var v2: Vector2i = GridManager.i.get_entity_grid_pos(entity)
	return GridManager.i.grid_to_position(v2)

func snap_entity_to_grid(entity:Entity):
	entity.global_position = get_entity_round_global_pos(entity)
	_entity_update(entity, entity.global_position)
	pass

func register_entity(entity: Entity):
	entity.entityGridUpdate.connect(_entity_update)
	entityList.append(entity)
	pass

func _entity_update(entity: Entity, pos):
	if pos is Vector3:
		pos = position_to_grid(pos)
		pass
	if entity is Player:
		pass
	if dictEntity2Grid.has(entity):
		if dictGrid2Entity.has(dictEntity2Grid[entity]):
			if dictGrid2Entity[dictEntity2Grid[entity]] == entity:
				dictGrid2Entity.erase(dictEntity2Grid[entity])
	dictEntity2Grid[entity] = pos
	dictGrid2Entity[pos] = entity
	pass
