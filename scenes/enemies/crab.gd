extends CharacterBody2D

@export var speed: float = 200.0
@export var fall_speed: float = 2000.0
@export var move_direction: Vector2 = Vector2.RIGHT

@onready var floor_ray_cast: RayCast2D = $FloorRayCast
@onready var wall_ray_cast: RayCast2D = $WallRayCast
@onready var corner_ray_cast: RayCast2D = $CornerRayCast

var floor_collide_recent = false
var airborne = false
var prev_pos = position

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
	print(velocity)
	prev_pos = position
	move_and_slide()
	if position == prev_pos:
		rotate(-PI/2)
		$Sprite2D.rotate(PI/2)
	$Sprite2D.rotate(delta * 10)
