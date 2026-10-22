extends CharacterBody2D
var total_rotate = 0.0
var speed = 60.0
var move_direction = Vector2.RIGHT
var surface_normal = Vector2.UP
@onready var FloorRayCast: RayCast2D = $FloorRayCast
@onready var WallRayCast: RayCast2D = $WallRayCast
@onready var CornerRayCast: RayCast2D = $CornerRayCast

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$Sprite2D.rotation = total_rotate
	total_rotate += delta * 2 * PI
	if total_rotate >= 2*PI:
		total_rotate -= 2*PI
func _physics_process(delta: float) -> void:
	var tangent = Vector2(-surface_normal.y, surface_normal.x) * move_direction
	velocity = tangent * speed
	move_and_slide()
	if not FloorRayCast.is_colliding():
		rotate_around_corner(1)
		return
	elif WallRayCast.is_colliding():
		rotate_around_corner(-1)
		return

func rotate_around_corner(dir: int) -> void:
	surface_normal = surface_normal.rotated(dir * PI / 2)
	rotation += dir * PI / 2
	if FloorRayCast: FloorRayCast.force_raycast_update()
	if WallRayCast: WallRayCast.force_raycast_update()
	if CornerRayCast: CornerRayCast.force_raycast_update()
