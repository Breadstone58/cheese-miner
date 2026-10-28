extends CharacterBody2D

@export var bullet_scene: PackedScene

var SPEED = 300.0
@export var ACCELERATION: float = 5000.0
@export var FRICTION: float = 1500.0

const JUMP_VELOCITY = -500.0
const AIR_TIME_MAX = 0.3
var air_time = AIR_TIME_MAX
var extra_jumps = 0
var extra_jumps_left = extra_jumps
var facing = GlobVar.charFacing
@export var toggle_lock_mode: bool = false
var is_position_locked: bool = false
var iFrames = 0
var dead = false
var crouching = false

var shoot_speed: float = 1.0/3.0
var shoot_cooldown: float = 0
var last_shot_dir = Vector2.ZERO

var dash_timer: float = 0.0
var dash_multiplier: float = 1.0
const DASH_DURATION: float = 0.2
const DASH_SPEED_MULTIPLIER: float = 2.5

var knockback_velocity: Vector2 = Vector2.ZERO
var cjb_active = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	position.x = GlobVar.PlayerX
	velocity.y = 2000
	SignalBus.bite_death.connect(_on_bite_kill)
	
func _process(delta: float) -> void:
	GlobVar.PlayerX = position.x
	
	if dash_timer > 0:
		dash_timer -= delta
		dash_multiplier = DASH_SPEED_MULTIPLIER
	else:
		dash_multiplier = 1.0
		
	iFrames -= 1
	iFrames = clamp(iFrames, 0, INF)
	if iFrames > 0:
		if sprite.modulate == Color(1,1,1,1):
			sprite.modulate = Color(255,255,255,0)
		else:
			sprite.modulate = Color(1,1,1,1)
	else:
		sprite.modulate = Color(1,1,1,1)
		
	if GlobVar.playerHealth <= 0:
		visible = false
		is_position_locked = true
		GlobVar.transitioning = true
		dead = true
		
	update_items()
	
	if Input.is_action_pressed("crouch") or $"Uncrouch Checker".is_colliding() or $"Uncrouch Checker2".is_colliding():
		if is_on_floor():
			SPEED /= 2.0
		$CollisionShape2D.shape.size.y = 60
		$CollisionShape2D.position.y = 34.0
		$BulletSpawnPoint.position.y = 32.0
		crouching = true
	else:
		$CollisionShape2D.shape.size.y = 120.0
		$CollisionShape2D.position.y = 4.0
		$BulletSpawnPoint.position.y = 0
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			if Input.is_action_pressed("aim_up"):
				$BulletSpawnPoint.position.y = 18
			elif Input.is_action_pressed("aim_down"):
				$BulletSpawnPoint.position.y = -18 
		crouching = false
		
	if Input.is_action_just_pressed("open_door_debug"):
		SignalBus.level_complete.emit()
		
	if Input.is_action_just_pressed("gadget"):
		if GlobVar.gadget != "":
			if GlobVar.energy > 0:
				GlobVar.energy -= 1
				activate_gadget()
	
	update_animation()
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

func _physics_process(delta: float) -> void:
	if GlobVar.biome == 1 and is_on_floor():
		FRICTION = 400.0
	else:
		FRICTION = 1500.0
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		air_time -= delta
		if not Input.is_action_pressed("jump") and extra_jumps_left == 0:
			air_time = 0
		if Input.is_action_just_pressed("jump") and extra_jumps_left > 0:
			extra_jumps_left -= 1
			air_time = AIR_TIME_MAX
			if Input.is_action_just_pressed("crouch"):
				cjb_active = true
	else:
		air_time = AIR_TIME_MAX
		extra_jumps_left = extra_jumps
		cjb_active = false
		
	handle_lock_input()

	if Input.is_action_pressed("jump") and air_time > 0 and not is_position_locked and not GlobVar.transitioning:
		velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("jump") and Input.is_action_just_pressed("crouch"):
			cjb_active = true
			

	var direction := Input.get_axis("move_left", "move_right")
	if dead:
		direction = 0
	
	if is_position_locked and direction != 0:
		facing = int(sign(direction))
		
	if is_position_locked:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	elif direction != 0:
		facing = int(sign(direction))
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, FRICTION * delta * 2)

	move_and_slide()
	
	if $StandingOnChecker.is_colliding() and $StandingOnChecker.get_collider() is TileMapLayer:
		var c = $StandingOnChecker.get_collider()
		if c.get_cell_source_id(c.local_to_map(c.to_local($StandingOnChecker.get_collision_point() - $StandingOnChecker.get_collision_normal()))) == 4:
			damage(5, position + Vector2(1, 0))

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and not GlobVar.transitioning and shoot_cooldown <= 0:
		shoot_cooldown = shoot_speed
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
			var knockback_dir = (global_position - location).normalized()
			knockback_dir.y = min(knockback_dir.y, -0.4)
			knockback_velocity = knockback_dir.normalized() * 600.0

func heal(amount: int):
	GlobVar.playerHealth = clamp(GlobVar.playerHealth + amount, 0, GlobVar.healthMax)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		damage(area.damage, area.global_position)
		
func update_items():
	SPEED = (300.0 + GlobVar.exMoveSpeed + (GlobVar.crouch_boost if cjb_active else 0.0)) * dash_multiplier
	extra_jumps = GlobVar.exJumps

func _on_bite_kill(healing: int):
	heal(healing + GlobVar.exBiteHeal)

func activate_gadget():
	match GlobVar.gadget:
		"Dash":
			dash_timer = DASH_DURATION
			velocity.x = facing * (SPEED * DASH_SPEED_MULTIPLIER)
		"Skeleton_Key":
			SignalBus.level_complete.emit()

func update_animation():
	sprite.scale.x = facing
	GlobVar.charFacing = facing
	var up = Input.is_action_pressed("aim_up")
	var down = Input.is_action_pressed("aim_down")
	var side = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	var aim_x = facing
	var v = Vector2(facing, 0)
	if not is_on_floor():
		sprite.animation = "jump_aim"
		if up and side:
			sprite.frame = 2
		elif up:
			sprite.frame = 1
		elif down and side:
			sprite.frame = 4
		elif down:
			sprite.frame = 5
		elif side:
			sprite.frame = 3
		else:
			if shoot_cooldown > 0:
				sprite.frame = 3
			else:
				sprite.frame = 0
	else:
		if crouching:
			if not ("crawl" in sprite.animation or "crouch" in sprite.animation):
				sprite.animation = "crouch_trans"
				sprite.play()
			if (sprite.animation == "crouch_trans" and sprite.frame == 3) or sprite.animation != "crouch_trans":
				if not(up or side or down):
					if shoot_cooldown > 0:
						sprite.animation = "crouch_idle_shoots"
						sprite.frame = 2
					else:
						sprite.animation = "crouch_idle"
						sprite.play()
				else:
					if is_position_locked:
						sprite.animation = "crouch_idle_shoots"
						if up and side:
							sprite.frame = 1
						elif down and side:
							sprite.frame = 3
						elif up:
							sprite.frame = 0
						elif down:
							sprite.frame = 4
						else:
							sprite.frame = 2
					else:
						if up and side:
							sprite.animation = "crawl_up_side"
							sprite.play()
						elif down and side:
							sprite.animation = "crawl_down_side"
							sprite.play()
						elif side:
							sprite.animation = "crawl_side"
							sprite.play()
						elif up:
							sprite.animation = "crouch_idle_shoots"
							sprite.frame = 0
						else:
							sprite.animation = "crouch_idle_shoots"
							sprite.frame = 4
		else:
			if "crawl" in sprite.animation or "crouch" in sprite.animation:
				sprite.animation = "stand_up"
				sprite.play()
			if (sprite.animation == "stand_up" and sprite.frame == 3) or sprite.animation != "stand_up":
				if not(up or side or down):
					if shoot_cooldown > 0:
						sprite.animation = "idle_aim"
						sprite.frame = 2
					else:
						sprite.animation = "idle"
						sprite.play()
				else:
					if is_position_locked:
						sprite.animation = "idle_aim"
						if up and side:
							sprite.frame = 1
						elif down and side:
							sprite.frame = 3
						elif up:
							sprite.frame = 0
						elif down:
							sprite.frame = 4
						else:
							sprite.frame = 2
					else:
						if up and side:
							sprite.animation = "walk_up_side"
							sprite.play()
						elif down and side:
							sprite.animation = "walk_down_side"
							sprite.play()
						elif side:
							sprite.animation = "walk_side"
							sprite.play()
						elif up:
							sprite.animation = "idle_aim"
							sprite.frame = 0
						else:
							sprite.animation = "idle_aim"
							sprite.frame = 4
			
			
			
