extends Node3D
class_name TitleScreen

var startButton: InWorldButton

signal startPressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startButton = $"Start Button"
	startButton.clicked.connect(start_pressed)
	startButton.isClickable = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_pressed():
	startButton.isClickable = false
	startPressed.emit()
	pass
