@tool
extends Node3D
class_name LevelManager

enum Mode {
	Off,
	SendingBlocks
}

var mode: Mode = Mode.Off
@export var dimensions: Vector2 = Vector2(7, 9)

var immovableBlockScene: PackedScene = load("res://entity/block/immovable_block.tscn")
var basicBlockScene: PackedScene = load("res://entity/block/basic_block.tscn")

var blockTimer: float = 0.0
var TIME_BT_BLOCKS: float = 2.0

const BLOCK_SIZE: float = 1.0
const OFFSET: Vector2 = Vector2(0.5, 0.5)
const Z_OFFSET: float = 0


var dictGrid2Entity: Dictionary[Vector2, Entity] = {}
var dictEntity2Grid: Dictionary[Entity, Vector2] = {}

@export var doUpdate: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	generate_level(dimensions)
	set_mode(Mode.SendingBlocks)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if doUpdate:
			generate_level(dimensions)
			doUpdate = false
			pass
	pass

func _physics_process(delta: float) -> void:
	match mode:
		Mode.Off:
			
			pass
		Mode.SendingBlocks:
			blockTimer -= delta
			if blockTimer < 0:
				spawn_block_from_current_pool()
				blockTimer = TIME_BT_BLOCKS
				pass
			pass
	pass

func set_mode(mode: Mode):
	self.mode = mode
	match mode:
		Mode.Off:
			
			pass
		Mode.SendingBlocks:
			
			pass
	pass

func generate_level(dimensions: Vector2, pos:Vector2 = Vector2.ZERO):
	for child in get_children():
		child.queue_free()
		pass
	dictGrid2Entity.clear()
	dictEntity2Grid.clear()
	
	var xval: float = pos.x - BLOCK_SIZE
	var yval: float = pos.y - BLOCK_SIZE
	print(xval)
	for x in range(0, dimensions.x + 2):
		spawn_block(immovableBlockScene, Vector2(xval + x, yval), true)
		pass
	for y in range(0, dimensions.y):
		spawn_block(immovableBlockScene, Vector2(xval, y + yval + BLOCK_SIZE), true)
		spawn_block(immovableBlockScene, Vector2(xval + dimensions.x + 1, y + yval + BLOCK_SIZE), true)
		pass
	pass

func get_player_start_position():
	#Vector2()
	#while get_grid_space()
	pass

func position_to_grid(pos) -> Vector2:
	pos /= BLOCK_SIZE
	return Vector2(round(pos.x), round(pos.y)) + OFFSET
	
func grid_to_position(grid:Vector2) -> Vector2:
	grid *= BLOCK_SIZE
	return grid + OFFSET

var topLeft: Vector2: 
	get:
		return Vector2(0, dimensions.y)
var topRight: Vector2: 
	get:
		return Vector2(dimensions.x, dimensions.y)

func spawn_block_from_current_pool():
	var randx: int = randi_range(0, dimensions.x-1)
	var pos: Vector2 = Vector2(randx, topLeft.y)
	
	
	var chosenScene: PackedScene = basicBlockScene
	var block: Block = await spawn_block(chosenScene, pos)
	
	return block

func spawn_block(blockScene: PackedScene, pos: Vector2, isBorder: bool = false):
	var block: Entity = await NodeSpawner.spawn(blockScene, get_tree())
	var gridPos: Vector2 = grid_to_position(pos)
	
	block.global_position = Vector3(gridPos.x, gridPos.y, Z_OFFSET)
	
	if not isBorder:
		block.entityGridUpdate.connect(_entity_update)
	block.reparent(self)
	return block

func get_grid_space(pos: Vector2):
	if dictGrid2Entity.has(pos):
		return dictGrid2Entity[pos]
	return null

func _entity_update(entity: Entity, pos: Vector2):
	if dictEntity2Grid.has(entity):
		if dictGrid2Entity.has(dictEntity2Grid[entity]):
			if dictGrid2Entity[dictEntity2Grid[entity]] == entity:
				dictGrid2Entity.erase(dictEntity2Grid[entity])
		dictEntity2Grid[entity] = pos
	dictGrid2Entity[pos] = entity
	pass
