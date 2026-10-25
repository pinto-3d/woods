@tool
extends Node3D
class_name GridManager

static var i: GridManager:
	get:
		if _i:
			return _i
		_i = (Engine.get_main_loop() as SceneTree).root.get_tree().get_nodes_in_group("grid_manager")[0]
		return _i
static var _i:GridManager


var root: Node3D

const BLOCK_SIZE: float = 1.0
const OFFSET: Vector2 = Vector2(0, 0)
const Z_OFFSET: float = 0

var MATCH_NUM: int = 4;

var dictGrid2Entity: Dictionary[Vector2i, Entity] = {}
var dictEntity2Grid: Dictionary[Entity, Vector2i] = {}

signal entity_registed(entity: Entity)
signal matchMade(count: int)

func _init() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GridManager.i != self:
		return
	root = get_tree().root.get_child(0)

func _process(delta: float) -> void:
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

func get_entity_at_grid_pos(pos: Vector2i):
	if dictGrid2Entity.has(pos):
		return dictGrid2Entity[pos]
	return null
func get_grid_pos_of_entity(entity: Entity):
	if dictEntity2Grid.has(entity):
		return dictEntity2Grid[entity]
	return null

func get_entity_round_global_pos(entity: Entity):
	var v2 = GridManager.i.get_grid_pos_of_entity(entity)
	if v2:
		return GridManager.i.grid_to_position(v2)
	return null

func snap_entity_to_grid(entity:Entity):
	if entity:
		var v3 = get_entity_round_global_pos(entity)
		if v3:
			entity.global_position = v3
			_entity_update(entity, entity.global_position)
	pass

func register_entity(entity: Entity):
	entity.entityGridUpdate.connect(_entity_update)
	entity.isRegisteredToGrid = true
	entity_registed.emit(entity)
	pass

func deregister_entity(entity: Entity):
	entity.entityGridUpdate.disconnect(_entity_update)
	var v2: Vector2i = dictEntity2Grid[entity]
	dictGrid2Entity.erase(v2)
	dictEntity2Grid.erase(entity)
	entity.erase()
	pass

func _does_block_match(entity, tint: Color) -> bool:
	if entity:
		if "TINT" in entity:
			if entity.TINT == tint:
				return true
	return false

func _check_tints_in_direction(tint: Color, start: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var turns: int = 0
	var continuing: bool = true
	var curEraseList: Array[Vector2i] = []
	var cursor: Vector2i = start
	
	while continuing:
		var curEntity = get_entity_at_grid_pos(cursor)
		if !_does_block_match(curEntity, tint):
			if turns == 0:
				direction *= -1
				cursor = start
			else:
				continuing = false
				break
			turns += 1
		else:
			curEraseList.append(cursor)
		cursor += direction
	if curEraseList.size() >= MATCH_NUM:
		return curEraseList
	return []

func _adjust_changed_entity(entity):
	if not entity is Block:
		return
	var block: Block = entity
	var tint: Color = block.TINT
	var v2: Vector2i = dictEntity2Grid[entity]
	
	var eraseList: Array[Vector2i] = []
	#horizontal
	var cursor: Vector2i = dictEntity2Grid[entity]
	eraseList.append_array(_check_tints_in_direction(tint, dictEntity2Grid[entity], Vector2(1,0)))
	eraseList.append_array(_check_tints_in_direction(tint, dictEntity2Grid[entity], Vector2(0,1)))
	eraseList.append_array(_check_tints_in_direction(tint, dictEntity2Grid[entity], Vector2(1,1)))
	eraseList.append_array(_check_tints_in_direction(tint, dictEntity2Grid[entity], Vector2(-1,1)))
	
	var erasedCount: int = 0
	for erasePos in eraseList:
		if dictGrid2Entity.has(erasePos):
			deregister_entity(dictGrid2Entity[erasePos])
			erasedCount += 1
		else:
			pass
		pass 
	matchMade.emit(erasedCount)

func _entity_update(entity: Entity, pos):
	if pos is Vector3:
		pos = position_to_grid(pos)
		pass
	if entity is Player:
		pass
	var prevPos = null
	if dictEntity2Grid.has(entity):
		prevPos = dictEntity2Grid[entity]
		if dictGrid2Entity.has(dictEntity2Grid[entity]):
			if dictGrid2Entity[dictEntity2Grid[entity]] == entity:
				dictGrid2Entity.erase(dictEntity2Grid[entity])
	dictEntity2Grid[entity] = pos
	dictGrid2Entity[pos] = entity
	
	if pos.y > LevelManager.i.topLeft.y:
		lost.emit()
	
	if prevPos != pos:
		_adjust_changed_entity(entity)
		pass
	pass

func lose():
	pass

signal lost
