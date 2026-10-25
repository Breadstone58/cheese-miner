extends CharacterBody2D

@export var speed: float = 200.0
@export var fall_speed: float = 500.0
@export var move_direction: Vector2 = Vector2.RIGHT

@onready var floor_ray_cast: RayCast2D = $FloorRayCast
@onready var wall_ray_cast: RayCast2D = $WallRayCast
@onready var corner_ray_cast: RayCast2D = $CornerRayCast

var floor_collide_recent = false
var airborne = false
var prev_pos = position
var health = 5 + 5 * floor(GlobVar.stage / 5.0)
var stunned = false
var stun_counter = 0
var unstun = 0

func _ready() -> void:
	$Hitbox.damage = 8 + GlobVar.stage * 2

func _physics_process(delta: float) -> void:
	if floor_ray_cast.is_colliding():
		floor_collide_recent = true
		airborne = false
		if wall_ray_cast.is_colliding():
			rotate(-PI/2)
			$Sprite2D.rotate(PI/2)
	elif corner_ray_cast.is_colliding() and floor_collide_recent:
		rotate(PI/2)
		$Sprite2D.rotate(-PI/2)
		floor_collide_recent = false
	elif not corner_ray_cast.is_colliding() and floor_collide_recent:
		rotation = 0
		airborne = true
	move_direction = Vector2(cos(rotation),sin(rotation))
	var dir_velocity = move_direction.normalized() * speed
	velocity = dir_velocity + Vector2(cos(rotation+(PI/2)),sin(rotation+(PI/2))) * speed
	if airborne:
		velocity.x = 0
		velocity.y = fall_speed
	prev_pos = position
	if stunned:
		velocity = Vector2(0,fall_speed)
	move_and_slide()
	if position == prev_pos and not stunned:
		rotate(-PI/2)
		$Sprite2D.rotate(PI/2)
	if not stunned:
		$Sprite2D.rotate(delta * 10)

func _process(delta: float) -> void:
	if health <= 0:
		stunned = true
	else:
		stunned = false
	if stunned:
		stun_counter += 1
		unstun += delta
		if stun_counter % 10 < 5:
			modulate = Color(1,1,1,1)
		else:
			modulate = Color(255,255,255,255)
	else:
		stun_counter = 0
		unstun = 0
	if unstun >= 10:
		health = 1
		modulate = Color(1,1,1,1)

func damage(amount: int,source: String):
	health -= amount
	if health <= 0 and source == "Bite":
		SignalBus.bite_death.emit(10)
		dead()
	if health <= -20:
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
		if randf() < ItemID.energy[GlobVar.gadget] / (100.0/3.0):
			ItemSpawner.spawn_item(global_position,13)
	ItemSpawner.spawn_money(global_position,clamp(randi_range(2 + 5 * floor(GlobVar.stage / 5.0),8 + 5 * floor(GlobVar.stage / 5.0)),1,INF))
	queue_free()
