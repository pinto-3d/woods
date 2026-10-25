extends CheckBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.i.isDebug:
		pass
	else:
		self.queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.i.isDebug:
		if Input.is_action_just_pressed("debug_stop_spawning"):
			match LevelManager.i.mode:
				LevelManager.Mode.Off:
					button_pressed = true
					pass
				LevelManager.Mode.SendingBlocks:
					button_pressed = false
					pass
				pass
	pass



func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		LevelManager.i.set_mode(LevelManager.Mode.SendingBlocks)
		pass
	else:
		LevelManager.i.set_mode(LevelManager.Mode.Off)
	pass # Replace with function body.
