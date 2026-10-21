extends CharacterBody2D

@export var bullet_scene: PackedScene

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const AIR_TIME_MAX = 0.3
var air_time = int(AIR_TIME_MAX)
var extra_jumps = 1
var extra_jumps_left = extra_jumps
# 1 for right, -1 for left
var facing = 1 
@export var toggle_lock_mode: bool = false
var is_position_locked: bool = false

func _ready() -> void:
	position.x = GlobVar.PlayerX
	velocity.y = 2000
	
func _process(_delta: float) -> void:
	GlobVar.PlayerX = position.x

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
	handle_lock_input()

	# Handle jump.
	if Input.is_action_pressed("jump") and air_time > 0 and not is_position_locked and not GlobVar.transitioning:
		velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	var current_aim = get_aim_vector()
	var is_aiming_diagonal_or_vertical = (current_aim.y != 0)
	if is_position_locked and direction != 0:
		facing = int(sign(direction))
	# Locks movement when aiming diagonally
	if is_position_locked:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction != 0:
		velocity.x = direction * SPEED
		facing = int(sign(direction))
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Determines which direction the player is aiming and returns a 
# vector representing the direction the bullet will shoot
func get_aim_vector() -> Vector2:
		var v = Vector2(facing, 0)
		var up = Input.is_action_pressed("aim_up")
		var down = Input.is_action_pressed("aim_down")
		var left = Input.is_action_pressed("move_left")
		var right = Input.is_action_pressed("move_right")
		var aim_x = facing
		if left:
			aim_x = -1
		if right:
			aim_x = 1
		if up:
			if left or right or (is_position_locked and (left or right)):
				return Vector2(aim_x * 0.707, -0.707)
			return Vector2(0, -1)
		elif down:
			if left or right:
				return Vector2(aim_x * 0.707, 0.707)
			return Vector2(0, 1)
		return Vector2(facing, 0)

# Handles shooting and spawning bullets
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and not GlobVar.transitioning:
		var bullet = bullet_scene.instantiate() as Area2D
		var aim_direction = get_aim_vector()
		bullet.global_position = $BulletSpawnPoint.global_position
		if bullet.has_method("setup"):
			bullet.setup(aim_direction)
		get_tree().current_scene.add_child(bullet)
		
func handle_lock_input() -> void:
	if toggle_lock_mode:
		if Input.is_action_just_pressed("lock_position"):
			is_position_locked = !is_position_locked
	else:
		is_position_locked = Input.is_action_pressed("lock_position")
