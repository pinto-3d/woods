extends Character
class_name Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	leftRay = $LeftRay
	rightRay = $RightRay
	groundRays = [
		$GroundRay/Left,
		$GroundRay/Right
	]
	hasLinearGravity = false
	start()
	pass # Replace with function body.


func start():
	GridManager.i.register_entity(self)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	pass

func _physics_process(delta):
	super._physics_process(delta)
	
	match state:
		State.FREE:
			if isOnGround:
				if Input.is_action_pressed("down"):
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
				if crouchDetect:
					canUnDuck = len(crouchDetect.get_overlapping_bodies()) == 0

			# Handle jump.
			if isOnGround:
				if Input.is_action_just_pressed("jump"):
					jump()
			else:
				if wallOnLeft:
					if Input.is_action_just_pressed("jump"):
						_try_wall_jump(1)
				if wallOnRight:
					if Input.is_action_just_pressed("jump"):
						_try_wall_jump(-1)
			
			if Input.is_action_just_pressed("interact"):
				if inputVector == Vector2.ZERO:
					inputVector.x = direction
					pass
				_try_interact(inputVector)
				pass
			
			publicVelocity = velocity
		State.SPAWNING:
			pass
		State.DISABLE_COMPLETELY:
			pass
		State.DYING:
			pass
		State.DISABLE_PHYSICS:
			pass

func jump():
	velocity.y = JUMP_VELOCITY

func get_inputVector():
	inputVector.x = Input.get_axis("left", "right")
	inputVector.y = Input.get_axis("up", "down")
	
	if inputVector.x > MIN_VELOCITY * sign(inputVector.x):
		direction = RelativeDirection.RIGHT
	elif inputVector.x < MIN_VELOCITY * sign(inputVector.x):
		direction = RelativeDirection.LEFT
	return inputVector

func iteracted_with(entity: Entity):
	super.iteracted_with(entity)
	pass
