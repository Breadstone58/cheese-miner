extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const AIR_TIME_MAX = 0.3
var air_time = int(AIR_TIME_MAX)
var extra_jumps = 1
var extra_jumps_left = extra_jumps
var facing = "right"


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		air_time -= delta
		if not Input.is_action_pressed("jump") and extra_jumps_left == 0:
			air_time = 0
		if Input.is_action_just_pressed("jump") and extra_jumps_left > 0:
			extra_jumps_left -= 1
			air_time = AIR_TIME_MAX
	else:
		air_time = AIR_TIME_MAX
		extra_jumps_left = extra_jumps

	# Handle jump.
	if Input.is_action_pressed("jump") and air_time > 0:
		velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
