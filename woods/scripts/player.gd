extends Character
class_name Player

var anim: LilGuyAnimations


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	leftRay = $LeftRay
	rightRay = $RightRay
	groundRays = [
		$GroundRay/Left,
		$GroundRay/Right
	]
	anim = $Armature
	hasLinearGravity = false
	start()
	pass # Replace with function body.


func start():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	pass

func _physics_process(delta):
	super._physics_process(delta)
	
	match state:
		State.FREE:
			anim.set_is_holding(isHolding)
			anim.isOnGround = isOnGround
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
			if Input.is_action_just_pressed("jump"):
				try_jump()
			
			if Input.is_action_just_pressed("interact"):
				if inputVector == Vector2.ZERO:
					inputVector.x = direction
					pass
				_try_interact(inputVector)
				pass
			if Input.is_action_just_pressed("place"):
				if inputVector == Vector2.ZERO:
					inputVector.x = direction
					pass
				_try_place(inputVector)
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

func direction_updated():
	anim.set_direction(direction)
	match direction:
		RelativeDirection.LEFT:
			if armature:
				armature.scale.x = 1
			pass
		RelativeDirection.RIGHT:
			if armature:
				armature.scale.x = -1
			pass
	pass
	
func _try_place(dir: Vector2i):
	if not heldEntity:
		return
	
	var playerV2: Vector2i = GridManager.i.get_grid_pos_of_entity(self)
	var posList: Array[Vector2i] = [
		Vector2i(1,0),
		Vector2i(1,1)
	]
	var placable: bool = true
	var i: int = 0
	var pos = playerV2 + posList[i]
	var posEntity = GridManager.i.get_entity_at_grid_pos(pos)
	while posEntity:
		i += 1
		if i < posList.size():
			pos = playerV2 + posList[i]
			posEntity = GridManager.i.get_entity_at_grid_pos(pos)
		else:
			placable = false
		pass
	
	if placable:
		place(pos)
		
func place(pos: Vector2i):
	if heldEntity:
		heldEntity.was_thrown()
		self.remove_collision_exception_with(heldEntity)
		GridManager.i.grid_to_position(pos)
		heldEntity.global_position = Vector3(pos.x, pos.y, 0)
		heldEntity.reparent(GridManager.i.root, true)
		heldEntity = null
	pass

func jump():
	velocity.y = JUMP_VELOCITY
	pass

func try_jump():
	if isOnGround:
		jump()
	else:
		if direction == RelativeDirection.LEFT:
			if wallOnLeft:
				_try_wall_jump(1)
			elif wallOnRight:
				_try_wall_jump(-1)
		elif direction == RelativeDirection.RIGHT:
			if wallOnRight:
				_try_wall_jump(-1)
			elif wallOnLeft:
				_try_wall_jump(1)

func get_inputVector():
	inputVector.x = Input.get_axis("left", "right")
	inputVector.y = Input.get_axis("down", "up")
	
	if inputVector.x > MIN_VELOCITY * sign(inputVector.x):
		set_direction(RelativeDirection.RIGHT)
		anim.set_is_walking(true)
	elif inputVector.x < MIN_VELOCITY * sign(inputVector.x):
		set_direction(RelativeDirection.LEFT)
		anim.set_is_walking(true)
	else:
		anim.set_is_walking(false)
	return inputVector

func iteracted_with(entity: Entity):
	super.iteracted_with(entity)
	pass
