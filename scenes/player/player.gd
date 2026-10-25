extends CharacterBody2D

@export var bullet_scene: PackedScene

var SPEED = 300.0
@export var ACCELERATION: float = 5000.0
@export var FRICTION: float = 1000.0

const JUMP_VELOCITY = -500.0
const AIR_TIME_MAX = 0.3
var air_time = AIR_TIME_MAX
var extra_jumps = 0
var extra_jumps_left = extra_jumps
# 1 for right, -1 for left
var facing = 1 
@export var toggle_lock_mode: bool = false
var is_position_locked: bool = false
var iFrames = 0

# Dash variables
var dash_timer: float = 0.0
var dash_multiplier: float = 1.0
const DASH_DURATION: float = 0.2
const DASH_SPEED_MULTIPLIER: float = 2.5

func _ready() -> void:
	position.x = GlobVar.PlayerX
	velocity.y = 2000
	SignalBus.bite_death.connect(_on_bite_kill)
	
func _process(delta: float) -> void:
	GlobVar.PlayerX = position.x
	
	# Handle dash timer countdown
	if dash_timer > 0:
		dash_timer -= delta
		dash_multiplier = DASH_SPEED_MULTIPLIER
	else:
		dash_multiplier = 1.0
		
	iFrames -= 1
	iFrames = clamp(iFrames, 0, INF)
	if iFrames > 0:
		if $AnimatedSprite2D.modulate == Color(1,1,1,1):
			$AnimatedSprite2D.modulate = Color(255,255,255,0)
		else:
			$AnimatedSprite2D.modulate = Color(1,1,1,1)
	else:
		$AnimatedSprite2D.modulate = Color(1,1,1,1)
		
	if GlobVar.playerHealth <= 0:
		visible = false
		is_position_locked = true
		GlobVar.transitioning = true
		
	update_items()
	
	if Input.is_action_pressed("crouch") or $"Uncrouch Checker".is_colliding() or $"Uncrouch Checker2".is_colliding():
		SPEED /= 2.0
		$AnimatedSprite2D.scale.y = 0.5
		$AnimatedSprite2D.position.y = 32.0
		$CollisionShape2D.shape.size.y = 60
		$CollisionShape2D.position.y = 34.0
		$BulletSpawnPoint.position.y = 32.0
	else:
		$AnimatedSprite2D.scale.y = 1.0
		$AnimatedSprite2D.position.y = 0.0
		$CollisionShape2D.shape.size.y = 120.0
		$CollisionShape2D.position.y = 4.0
		$BulletSpawnPoint.position.y = 0
		
	if Input.is_action_just_pressed("open_door_debug"):
		SignalBus.level_complete.emit()
		
	if Input.is_action_just_pressed("gadget"):
		if GlobVar.gadget != "":
			if GlobVar.energy > 0:
				GlobVar.energy -= 1
				activate_gadget()

func _physics_process(delta: float) -> void:
	# Add the gravity
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

	# Get the input direction and handle acceleration/friction.
	var direction := Input.get_axis("move_left", "move_right")
	
	if is_position_locked and direction != 0:
		facing = int(sign(direction))
		
	# Locks movement when aiming diagonally or position locked
	if is_position_locked:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	elif direction != 0:
		facing = int(sign(direction))
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

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
		var bullet = bullet_scene.instantiate()
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

func damage(amount: int, location: Vector2 = Vector2(-1,-1)):
	if iFrames == 0 and GlobVar.playerHealth > 0:
		GlobVar.playerHealth -= amount
		iFrames = 60
		if location != Vector2(-1,-1):
			velocity = (global_position - location).normalized() * 1000
		move_and_slide()

func heal(amount: int):
	GlobVar.playerHealth = clamp(GlobVar.playerHealth + amount, 0, GlobVar.healthMax)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		damage(area.damage, area.global_position)
		
func update_items():
	SPEED = (300.0 + GlobVar.exMoveSpeed) * dash_multiplier
	extra_jumps = GlobVar.exJumps

func _on_bite_kill(healing: int):
	heal(healing + GlobVar.exBiteHeal)

func activate_gadget():
	match GlobVar.gadget:
		"dash":
			dash_timer = DASH_DURATION
			velocity.x = facing * (SPEED * DASH_SPEED_MULTIPLIER)
