extends Node3D
class_name LoseScreen

var retryButton: InWorldButton

signal retryPressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	retryButton = $Retry
	retryButton.clicked.connect(retry_pressed)
	retryButton.isClickable = true
	pass # Replace with function body.

func lost():
	visible = true
	retryButton.isClickable = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func retry_pressed():
	retryButton.isClickable = false
	retryPressed.emit()
	pass
