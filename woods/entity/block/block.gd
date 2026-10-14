@tool
extends Entity
class_name Block

@export var TEX_SEED: float;
@export var BRIGHTNESS_MIN_MAX: Vector2 = Vector2(0, 1)
@export var TINT: Color
@export var RESOLUTION: int = 8;

var _tex_seed
var _brightness_min_max
var _tint
var _resolution

var debugLabel3d: Label3D

func _init() -> void:
	super._init()

func _ready() -> void:
	super._ready()
	mesh = $MeshInstance3D
	col = $CollisionShape3D
	debugLabel3d = get_node_or_null("DebugLabel3D")
	TEX_SEED = global_position.x
	
	mesh.material_override.set("shader_parameter/seed", TEX_SEED);
	mesh.material_override.set("shader_parameter/min_brightness", BRIGHTNESS_MIN_MAX.x);
	mesh.material_override.set("shader_parameter/max_brightness", BRIGHTNESS_MIN_MAX.y);
	mesh.material_override.set("shader_parameter/tint", TINT);
	mesh.material_override.set("shader_parameter/resolution", RESOLUTION);

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		if not mesh:
			mesh = $MeshInstance3D
		mesh.material_override.set("shader_parameter/seed", TEX_SEED);
		mesh.material_override.set("shader_parameter/min_brightness", BRIGHTNESS_MIN_MAX.x);
		mesh.material_override.set("shader_parameter/max_brightness", BRIGHTNESS_MIN_MAX.y);
		mesh.material_override.set("shader_parameter/tint", TINT);
		mesh.material_override.set("shader_parameter/resolution", RESOLUTION);
	pass

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not mesh:
			mesh = $MeshInstance3D
		if _tex_seed != TEX_SEED:
			mesh.material_override.set("shader_parameter/seed", TEX_SEED);
			_tex_seed = TEX_SEED
		if _brightness_min_max != BRIGHTNESS_MIN_MAX:
			mesh.material_override.set("shader_parameter/min_brightness", BRIGHTNESS_MIN_MAX.x);
			mesh.material_override.set("shader_parameter/max_brightness", BRIGHTNESS_MIN_MAX.y);
			_brightness_min_max = BRIGHTNESS_MIN_MAX
		if _tint != TINT:
			if TINT is Color:
				set_color(TINT)
		if _resolution != RESOLUTION:
			mesh.material_override.set("shader_parameter/resolution", RESOLUTION);
			_resolution = RESOLUTION
		return
	super._process(delta)
	if debugLabel3d:
		debugLabel3d.text = ""
		var v2 = GridManager.i.get_entity_grid_pos(self)
		if v2:
			debugLabel3d.text += str(v2) + "\n"
		if heldEntity:
			v2 = GridManager.i.get_entity_grid_pos(heldEntity)
			if v2:
				debugLabel3d.text += ".  "+str(v2) + "\n"
		else:
				debugLabel3d.text += ".  " + "\n"
		debugLabel3d.text += str(isHeld) + "\n"

func set_color(color: Color):
	
	_tint = color
	TINT = color
	mesh.material_override.set("shader_parameter/tint", TINT);
	pass

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super._physics_process(delta)

func iteracted_with(entity: Entity):
	super.iteracted_with(entity)
	pass
