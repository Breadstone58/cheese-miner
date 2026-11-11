extends CharacterBody2D

var bullet_scene = preload("res://scenes/bullet/bullet.tscn")
var sawblade_gadget = preload("res://scenes/player/items/sawblade.tscn")

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
var jump_sfx_played = false

var shoot_speed: float = 15.0/60.0
var shoot_cooldown: float = 0
var last_shot_dir = Vector2.ZERO

var dash_timer: float = 0.0
var dash_multiplier: float = 1.0
const DASH_DURATION: float = 0.2
const DASH_SPEED_MULTIPLIER: float = 2.5

var knockback_velocity: Vector2 = Vector2.ZERO
var cjb_active = false
var jump_buffer_timer: float = 0.0
var crouch_buffer_timer: float = 0.0
const INPUT_BUFFER_WINDOW: float = 3.0/60.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if get_tree().current_scene.name == "Title":
		position.x = 541
	else:
		position.x = GlobVar.PlayerX
	velocity.y = 2000
	SignalBus.bite_death.connect(_on_bite_kill)
	
func _process(delta: float) -> void:
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	crouch_buffer_timer = max(0.0, crouch_buffer_timer - delta)
	
	# Capture inputs when they are just pressed
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = INPUT_BUFFER_WINDOW
			
	if Input.is_action_just_pressed("crouch"):
		crouch_buffer_timer = INPUT_BUFFER_WINDOW
	GlobVar.PlayerX = position.x
	GlobVar.PlayerY = position.y
	
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
		
	if GlobVar.playerHealth <= 0 and not dead:
		dead = true
		$Sounds/CheddyDeath.play()
		$AnimationPlayer.play("manimdead")
		await $AnimationPlayer.animation_finished 
		visible = false
		is_position_locked = true
		GlobVar.transitioning = true
		dead = true
		# await get_tree().create_timer(2.0).timeout
		SceneTransitions.transition_to("res://scenes/death_screen.tscn",1.0)
		
	update_items()
	
	if Input.is_action_pressed("crouch") or $"Uncrouch Checker".is_colliding() or $"Uncrouch Checker2".is_colliding():
		if is_on_floor():
			SPEED /= 2.0
		$CollisionShape2D.shape.size.y = 60
		$Hurtbox/CollisionShape2D.shape.size.y = 63
		$CollisionShape2D.position.y = 34.0
		$Hurtbox/CollisionShape2D.position.y = 32.5
		$BulletSpawnPoint.position.y = 32.0
		if Input.is_action_pressed("aim_up") or Input.is_action_pressed("aim_down"):
			$BulletSpawnPoint.position.x = 34.0 * facing
		else:
			$BulletSpawnPoint.position.x = 0
		crouching = true
	else:
		$CollisionShape2D.shape.size.y = 120.0
		$Hurtbox/CollisionShape2D.shape.size.y = 127.0
		$CollisionShape2D.position.y = 4.0
		$Hurtbox/CollisionShape2D.position.y = 0.5
		$BulletSpawnPoint.position = Vector2(0,0)
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			if Input.is_action_pressed("aim_up"):
				$BulletSpawnPoint.position.y = 22
			elif Input.is_action_pressed("aim_down"):
				$BulletSpawnPoint.position.y = -22 
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
		FRICTION = min(400.0 + 220 * GlobVar.environmentalRes,1500)
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
			$Sounds/Jump.play()
	else:
		air_time = AIR_TIME_MAX
		extra_jumps_left = extra_jumps
		cjb_active = false
		jump_sfx_played = false
		
	handle_lock_input()	
	
	if Input.is_action_pressed("jump") and air_time > 0 and not is_position_locked and not GlobVar.transitioning:
		velocity.y = JUMP_VELOCITY
		if jump_buffer_timer > 0.0 and crouch_buffer_timer > 0.0:
			cjb_active = true
			if facing == 1:
				$AnimationPlayer.play("CrouchJump")
			else:
				$AnimationPlayer.play("CrouchJumpR")
		if not jump_sfx_played:
			$Sounds/Jump.play()
			jump_sfx_played = true
			
	# Experimental bite-dash
	"""
	if Input.is_action_just_pressed("bite"):
		dash_timer = 0.15
		if velocity.x == 0:
			velocity.x += facing * 500
		else:
			velocity.x = facing * 1.5
	"""

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
			damage(max(5-GlobVar.environmentalRes,0), position + Vector2(1, 0))

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
	if event.is_action_pressed("shoot") and not GlobVar.transitioning and shoot_cooldown <= 2.0/60.0:
		await get_tree().create_timer(shoot_cooldown).timeout
		shoot_cooldown = shoot_speed
		
		var bullet = bullet_scene.instantiate()
		var aim_direction = get_aim_vector()
		bullet.global_position = $BulletSpawnPoint.global_position
		if bullet.has_method("setup"):
			bullet.setup(aim_direction)
		get_tree().current_scene.add_child(bullet)
		$Sounds/Shoot.play()
		
func handle_lock_input() -> void:
	if toggle_lock_mode:
		if Input.is_action_just_pressed("lock_position"):
			is_position_locked = !is_position_locked
	else:
		is_position_locked = Input.is_action_pressed("lock_position")

func damage(amount: int, location: Vector2 = Vector2(-1,-1)):
	if iFrames == 0 and GlobVar.playerHealth > 0:
		GlobVar.FracHealth -= amount
		iFrames = 60
		if GlobVar.playerHealth > 0:
			$Sounds/Hurt.play()
		else:
			$Sounds/Death.play(0.22)
			#$Sounds/CheddyDeath.play()
		if location != Vector2(-1,-1):
			var knockback_dir = (global_position - location).normalized()
			knockback_dir.y = min(knockback_dir.y, -0.4)
			knockback_velocity = knockback_dir.normalized() * 600.0

func heal(amount: int):
	GlobVar.FracHealth = clamp(GlobVar.FracHealth + amount, 0, GlobVar.healthMax if not GlobVar.goOverMaxHp else INF)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		damage(area.damage, area.global_position)
		
func update_items():
	SPEED = (300.0 + GlobVar.exMoveSpeed + (GlobVar.crouch_boost if cjb_active else 0.0)) * dash_multiplier
	extra_jumps = GlobVar.exJumps
	shoot_speed = clamp(0.25 + GlobVar.exAttackSpeed,1.0/60.0,INF)


func _on_bite_kill(healing: int):
	heal(healing + GlobVar.exBiteHeal)
	if healing + GlobVar.exBiteHeal > 0:
		$AnimationPlayer.play("Heal Aura")
	else:
		$AnimationPlayer.play("Maggot Aura")
	# experimental bite dash:
	# velocity.y = -650
	# velocity.x = facing * -500
	

func activate_gadget():
	match GlobVar.gadget:
		"Dash":
			dash_timer = DASH_DURATION
			velocity.x = facing * (SPEED * DASH_SPEED_MULTIPLIER)
		"Skeleton_Key":
			SignalBus.level_complete.emit()
		"Sawblade":
			var saw = sawblade_gadget.instantiate()
			saw.global_position = global_position
			saw.init_dir = facing
			get_tree().current_scene.add_child(saw)
		
			

func update_animation():
	sprite.scale.x = facing
	GlobVar.charFacing = facing
	var up = Input.is_action_pressed("aim_up")
	var down = Input.is_action_pressed("aim_down")
	var side = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	var aim_x = facing
	var v = Vector2(facing, 0)
	#if GlobVar.playerHealth <= 0:
		#$Sounds/CheddyDeath.play()
	if cjb_active and not is_on_floor():
		if sprite.animation != "cj":
			sprite.animation = "cj"
			sprite.play()
			await sprite.animation_finished 
		return
	else:
		pass
	if iFrames != 0:
		if sprite.animation != "hurt":
			sprite.animation = "hurt"
			sprite.play()
			# $AnimationPlayer.play("Hurt") nvm this shit looks like hot ASS
			await $AnimationPlayer.animation_finished 
		return
	elif Input.is_action_just_pressed("bite") and not crouching:
		if sprite.animation != "still_bite":
			sprite.animation = "still_bite"
			sprite.play()
	if sprite.animation == "still_bite" and sprite.is_playing():
		return
	elif not is_on_floor() and not crouching: 
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
		if crouching and not cjb_active: # going to make a cjb anim/frame so this needs to be added
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
	if is_on_floor() and not crouching and side and not $Sounds/Walk.is_playing():
		$Sounds/Walk.play()
	elif not is_on_floor() or crouching or not side:
		$Sounds/Walk.stop()
	if is_on_floor() and crouching and side and not $Sounds/CrouchWalk.is_playing():
		$Sounds/CrouchWalk.play()
	elif not is_on_floor() or not crouching or not side:
		$Sounds/CrouchWalk.stop()
