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

func _init() -> void:
	super._init()

func _ready() -> void:
	super._ready()
	mesh = $MeshInstance3D
	col = $CollisionShape3D
	print("he")
	TEX_SEED = global_position.x
	
	mesh.material_override.set("shader_parameter/seed", TEX_SEED);
	mesh.material_override.set("shader_parameter/min_brightness", BRIGHTNESS_MIN_MAX.x);
	mesh.material_override.set("shader_parameter/max_brightness", BRIGHTNESS_MIN_MAX.y);
	mesh.material_override.set("shader_parameter/tint", TINT);
	mesh.material_override.set("shader_parameter/resolution", RESOLUTION);

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
			mesh.material_override.set("shader_parameter/tint", TINT);
			_tint = TINT
		if _resolution != RESOLUTION:
			mesh.material_override.set("shader_parameter/resolution", RESOLUTION);
			_resolution = RESOLUTION
		pass
		return
	super._process(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super._physics_process(delta)
