extends CharacterBody2D

const ROTATE_SPEED = 5.0
const SPEED = 800.0

var health = 5 + 5 * floor(GlobVar.stage / 5.0)
var stunned = false
var stun_counter = 0
var unstun = 0
var state = 1:
	set(value):
		state = value
		if value == 3:
			direction = global_position.direction_to(Vector2(GlobVar.PlayerX,GlobVar.PlayerY))
var target_timer = 0
var charge_timer = 1
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hitbox.damage = int(9 + GlobVar.stage * 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not stunned:
		if state == 1:
			velocity = Vector2.ZERO
			charge_timer += delta
			$AnimationPlayer.play("idleloop")
			$AnimatedSprite2D.play()
			rotation = rotate_toward(rotation,0,ROTATE_SPEED * delta)
			target_timer = 0
			if charge_timer >= 1 and $DetectionRange.has_overlapping_areas():
				state = 2
		if state == 2:
			charge_timer = 0
			velocity = Vector2.ZERO
			$AnimationPlayer.play("attack")
			$AnimatedSprite2D.play()
			rotation = rotate_toward(rotation,PI/2.0 + global_position.angle_to_point(Vector2(GlobVar.PlayerX,GlobVar.PlayerY)),ROTATE_SPEED * delta)
			target_timer += delta
			if target_timer >= 1:
				state = 3
		if state == 3:
			$AnimationPlayer.stop()
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.frame = 4
			var collision = move_and_collide(direction.normalized() * SPEED * delta)
			if collision:
				state = 1
	
	if health <= 0:
		stunned = true
	else:
		stunned = false
	if stunned:
		$AnimationPlayer.stop()
		$AnimatedSprite2D.stop()
		stun_counter += 1
		unstun += delta
		if stun_counter % 10 < 5:
			modulate = Color(1,1,1,1)
		else:
			modulate = Color(255,255,255,255)
		velocity = Vector2(0,500)
		move_and_slide()
	else:
		stun_counter = 0
		unstun = 0
	if unstun >= 3 + GlobVar.exStunTime:
		health = 1
		state = 1
		modulate = Color(1,1,1,1)

func _on_detection_range_area_entered(area: Area2D) -> void:
	if state == 1:
		state = 2
	
func reset_look():
	await get_tree().create_timer(1.0).timeout
	$DetectionRange.monitoring = false
	$DetectionRange.monitoring = true
	
func damage(amount: int,source: String):
	health -= amount
	if health <= 0 and source == "Bite":
		SignalBus.bite_death.emit(10)
		dead()
	elif health <= -20 and (GlobVar.canBullletKill if source == "bullet" else true):
		dead()
	modulate = Color(255,0,0,255)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1,1)
	

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Bite:
		damage(area.damage,"Bite")

func dead():
	if GlobVar.gadget != "":
		randomize()
		if randf() < ItemID.energy[GlobVar.gadget] / (100.0/3.0) and GlobVar.energy < ItemID.energy[GlobVar.gadget]:
			ItemSpawner.spawn_item(global_position,13)
	ItemSpawner.spawn_money(global_position,clamp(randi_range(2 + 5 * floor(GlobVar.stage / 5.0),8 + 5 * floor(GlobVar.stage / 5.0)),1,INF))
	SignalBus.enemy_killed.emit()
	queue_free()
