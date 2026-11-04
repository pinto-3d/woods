extends MeshInstance3D

var SWAY_AMOUNT: float = 90
var SWAY_LERP: float = 100

var swayGoal: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_goal(SWAY_AMOUNT)
	pass # Replace with function body.


func set_goal(rot: float):
	swayGoal = Vector3(rotation_degrees.x, rotation_degrees.y, rot)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(rotation_degrees.angle_to(swayGoal) > 0.1):
		rotation_degrees.lerp(swayGoal, SWAY_LERP * delta)
		pass
	
	pass
