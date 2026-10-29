@tool
extends Node3D
class_name LevelManager

enum Mode {
	Off,
	SendingBlocks
}

enum BlockColor {
	PINK,
	BLUE,
	RED,
	YELLOW,
	GREEN,
	WHITE,
	BORDER
}

var dictColors: Dictionary[BlockColor, Color] = {
	BlockColor.PINK: Color(0.682, 0.0, 0.705, 1.0),
	BlockColor.BLUE: Color(0.0, 0.502, 1.0, 1.0),
	BlockColor.RED: Color(1.0, 0.0, 0.502, 1.0),
	BlockColor.YELLOW: Color(1.0, 1.0, 0.502, 1.0),
	BlockColor.GREEN: Color(0.0, 1.0, 0.502, 1.0),
	BlockColor.WHITE: Color(0.502, 0.502, 0.502, 1.0),
	BlockColor.BORDER: Color(0.502, 0.0, 0.502, 1.0),
}

var availableColors: Array[BlockColor] = [
	BlockColor.RED,
	BlockColor.BLUE,
	BlockColor.YELLOW,
	BlockColor.PINK
]

static var i: LevelManager

var mode: Mode = Mode.Off
@export var dimensions: Vector2 = Vector2(7, 9)
var offset: Vector2 = Vector2(5, 0);

var immovableBlockScene: PackedScene = load("res://entity/block/immovable_block.tscn")
var basicBlockScene: PackedScene = load("res://entity/block/basic_block.tscn")

var timeSinceLevelStart: float = 0

var blockTimer: float = 0.0
var currentTimeBtBlocks: float = 2
var BASE_TIME_BT_BLOCKS: float = 2
var DECREASE_BT_BLOCKS_INC: float = 0.1
var DECREASE_BT_BLOCKS_LOG: float = 2

var BLOCK_SPAWN_Y: int = 12
var DEATH_Y: int = 10

var topLeft: Vector2: 
	get:
		return Vector2(0, dimensions.y) + offset
var topRight: Vector2: 
	get:
		return Vector2(dimensions.x, dimensions.y) + offset
var middle: Vector2:
	get:
		return Vector2(round(dimensions.x/2), dimensions.y) + offset

@export var doUpdate: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if LevelManager.i:
		return
	LevelManager.i = self
	GridManager.i.entity_moved.connect(block_moved)
	start_new_level()

func block_moved(entity: Entity, gridPosition: Vector2i):
	if entity is Block:
		if gridPosition.y > DEATH_Y:
			
			pass
	pass

func decrease_time_bt_blocks(amt: int):
	var mult: int = log(amt + 1)/log(DECREASE_BT_BLOCKS_LOG)
	currentTimeBtBlocks = BASE_TIME_BT_BLOCKS - (mult * DECREASE_BT_BLOCKS_INC)
	pass

func start_new_level():
	generate_level(dimensions, offset)
	set_mode(Mode.SendingBlocks)
	currentTimeBtBlocks = BASE_TIME_BT_BLOCKS
	timeSinceLevelStart = 0
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if doUpdate:
			generate_level(dimensions, offset)
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
				decrease_time_bt_blocks(timeSinceLevelStart)
				blockTimer = currentTimeBtBlocks
				pass
			timeSinceLevelStart += delta
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
	GridManager.i.clear()
	
	GridManager.i.register_entity((Engine.get_main_loop() as SceneTree).root.get_tree().get_nodes_in_group("player")[0])
	
	var xval: float = pos.x - GridManager.i.BLOCK_SIZE
	var yval: float = pos.y - GridManager.i.BLOCK_SIZE
	print(xval)
	for x in range(0, dimensions.x + 2):
		spawn_block(immovableBlockScene, BlockColor.BORDER, Vector2(xval + x, yval), true)
		pass
	for y in range(0, dimensions.y):
		spawn_block(immovableBlockScene, BlockColor.BORDER, Vector2(xval, y + yval), true)
		spawn_block(immovableBlockScene, BlockColor.BORDER, Vector2(xval + dimensions.x + 1, y + yval), true)
		pass
	pass

func get_player_start_position():
	#Vector2()
	#while get_entity_at_grid_pos()
	pass

func spawn_block_from_current_pool():
	var randrange: Array[int] = []
	for i in range(0, dimensions.x):
		randrange.append(topLeft.x + i)
		pass
	
	var randxIndex: int = randi_range(0, randrange.size()-1)
	var randSpawnPoint: Vector2i = Vector2i(randrange[randxIndex], BLOCK_SPAWN_Y)
	while GridManager.i.get_entity_at_grid_pos(randSpawnPoint):
		randrange.remove_at(randxIndex)
		randxIndex = randi_range(0, randrange.size())
		randSpawnPoint = Vector2i(randrange[randxIndex], BLOCK_SPAWN_Y)
	
	var pos: Vector2 = randSpawnPoint
	
	var chosenScene: PackedScene = basicBlockScene
	
	var randc: int = randi_range(0, availableColors.size()-1)
	var color: BlockColor = availableColors[randc]
	
	var block: Block = await spawn_block(chosenScene, color, pos)
	
	return block

func spawn_block(blockScene: PackedScene, color:BlockColor, pos: Vector2i, isBorder: bool = false):
	var block: Entity = await NodeSpawner.spawn(blockScene, get_tree())
	if block is Block:
		block.set_color(dictColors[color])
		pass
	
	block.global_position = GridManager.i.grid_to_position(pos)
	
	if not isBorder:
		GridManager.i.register_entity(block)
	block.reparent(self)
	return block
