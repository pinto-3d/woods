extends Node3D
class_name GridManager

static var i: GridManager

const BLOCK_SIZE: float = 1.0
const OFFSET: Vector2 = Vector2(0.5, 0.5)
const Z_OFFSET: float = 0

var dictGrid2Entity: Dictionary[Vector2, Entity] = {}
var dictEntity2Grid: Dictionary[Entity, Vector2] = {}
var entityList: Array[Entity] = []

func _init() -> void:
	if GridManager.i:
		return
	GridManager.i = self
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GridManager.i:
		return
	GridManager.i = self

func _process(delta: float) -> void:
	if entityList.size() > 1:
		print("grav: ",entityList[1].GRAVITY_DIRECTION * entityList[1].GRAVITY)
		print("velo: ",entityList[1].velocity)
		print("dot:  ",entityList[1].velocity.dot(entityList[1].GRAVITY_DIRECTION * entityList[1].LINEAR_GRAVITY_MAX))
		print("dot2:  ",(entityList[1].GRAVITY_DIRECTION * entityList[1].LINEAR_GRAVITY_MAX).dot(entityList[1].velocity))
		pass
	pass

func clear():
	dictGrid2Entity.clear()
	dictEntity2Grid.clear()
	pass

func position_to_grid(pos) -> Vector2:
	pos /= BLOCK_SIZE
	return Vector2(round(pos.x), round(pos.y)) + OFFSET
	
func grid_to_position(grid:Vector2) -> Vector2:
	grid *= BLOCK_SIZE
	return grid + OFFSET

func get_grid_space(pos: Vector2):
	if dictGrid2Entity.has(pos):
		return dictGrid2Entity[pos]
	return null

func register_entity(entity: Entity):
	entity.entityGridUpdate.connect(_entity_update)
	entityList.append(entity)
	pass

func _entity_update(entity: Entity, pos):
	if pos is Vector3:
		pos = position_to_grid(pos)
		pass
	
	if dictEntity2Grid.has(entity):
		if dictGrid2Entity.has(dictEntity2Grid[entity]):
			if dictGrid2Entity[dictEntity2Grid[entity]] == entity:
				dictGrid2Entity.erase(dictEntity2Grid[entity])
		dictEntity2Grid[entity] = pos
	dictGrid2Entity[pos] = entity
	pass
