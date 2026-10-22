extends CharacterBody2D
var speed = 60.0
@onready var FloorRayCast: RayCast2D = $FloorRayCast
@onready var WallRayCast: RayCast2D = $WallRayCast
@onready var CornerRayCast: RayCast2D = $CornerRayCast
var just_rotated = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$Sprite2D.rotation += delta * 2 * PI

func _physics_process(delta: float) -> void:
	if just_rotated > 0:
		just_rotated -= 1
	var forward_vector = global_transform.x
	velocity = forward_vector * speed
	var collision = move_and_collide(velocity * delta)
	if just_rotated > 0:
		return
	
	if WallRayCast.is_colliding() or collision:
		rotate_around_corner(-1)
		return
		
	if not FloorRayCast.is_colliding():
		if CornerRayCast.is_colliding():
			var new_normal = CornerRayCast.get_collision_normal()
			global_rotation = new_normal.angle() + (PI / 2)
			global_position = CornerRayCast.get_collision_point() + (new_normal * 9.0)
			just_rotated = 3
			if FloorRayCast: FloorRayCast.force_raycast_update()
			if WallRayCast: WallRayCast.force_raycast_update()
			if CornerRayCast: CornerRayCast.force_raycast_update()
			return
		else:
			rotate_around_corner(1)
			return

func rotate_around_corner(dir: int) -> void:
	rotation += dir * PI / 2
	var push_normal = Vector2.UP.rotated(rotation)
	global_position += push_normal * 3.0
	just_rotated = 3
	if FloorRayCast: FloorRayCast.force_raycast_update()
	if WallRayCast: WallRayCast.force_raycast_update()
	if CornerRayCast: CornerRayCast.force_raycast_update()
