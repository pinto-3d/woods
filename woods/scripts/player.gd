extends Character
class_name Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	super._physics_process(delta)
	match state:
		State.FREE:
			get_inputVector()
			if velocity.length() > SPEED_LIMIT:
				velocity = velocity.normalized() * SPEED_LIMIT
				pass
			if velocity.x > SPEED_LIMIT:
				velocity.x = SPEED_LIMIT
			
			if isOnGround:
				if Input.is_action_pressed("duck") or Input.is_action_pressed("down"):
					isDucking = true
					if abs(velocity.x) > SLIDE_MIN_SPEED:
						isDuckingSlide = true
					else:
						isDuckingSlide = false
				else:
					if canUnDuck:
						isDuckingSlide = false
						isDucking = false
			else:
				isDuckingSlide = false
				isDucking = false
				canUnDuck = true
			
			if isDucking:
				canUnDuck = len(crouchDetect.get_overlapping_bodies()) == 0
			
			# Add the gravity.
			if not is_on_floor():
				velocity -= get_gravity() * delta

			# Handle jump.
			if isOnGround:
				if Input.is_action_just_pressed("jump"):
					velocity.y = JUMP_VELOCITY
			else:
				if wallOnLeft:
					if Input.is_action_just_pressed("jump"):
						wall_jump(1)
				if wallOnRight:
					if Input.is_action_just_pressed("jump"):
						wall_jump(-1)
			if abs(inputVector.x) > INPUT_DEADZONE:
				if isDucking:
					if not isDuckingSlide:
						velocity.x = move_toward(velocity.x, MAX_CROUCH_SPEED * direction, ACCELERATION * delta)
				else:
					if isOnGround:
						velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION * delta)
					else:
						if sign(velocity.x) != direction or abs(velocity.x) < abs(MAX_SPEED):
							velocity.x = move_toward(velocity.x, MAX_SPEED * direction, ACCELERATION * delta)
			else:
				if isOnGround:
					velocity.x = move_toward(velocity.x, 0.0, DECCELERATION * delta)
			
			
			publicVelocity = velocity
		State.SPAWNING:
			pass
		State.DISABLE_COMPLETELY:
			pass
		State.DYING:
			pass
		State.DISABLE_PHYSICS:
			pass
