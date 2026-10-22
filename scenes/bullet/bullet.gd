extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT
var bounces: int = 0

@onready var ray_front: RayCast2D = $RayCast2D
@onready var ray_back: RayCast2D = $RayCast2D2

func setup(dir: Vector2) -> void:
	direction = dir.normalized()
	bounces = GlobVar.bulletBounces
	print(bounces)
	# Point both raycasts forward, but stagger their lengths/positions slightly 
	# to cover a wider front area
	if ray_front:
		ray_front.target_position = direction * 25
	if ray_back:
		# Stagger the second one slightly shorter or offset for multi-point coverage
		ray_back.target_position = direction * 15

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation = direction.angle()
	# Check if either raycast detects a collision
	var active_ray: RayCast2D = null
	if ray_front and ray_front.is_colliding():
		active_ray = ray_front
	elif ray_back and ray_back.is_colliding():
		active_ray = ray_back
		
	if active_ray != null:
		var body = active_ray.get_collider()
		
		if body is TileMapLayer:
			var hit_point = active_ray.get_collision_point()
			# Push slightly inward from whichever raycast hit the tile
			var tile_coords = body.local_to_map(body.to_local(hit_point + (direction * 2)))
			
			var tile_data = body.get_cell_tile_data(tile_coords)
			if tile_data != null and tile_data.get_custom_data("breakable") == true:
				SignalBus.spawn_particle.emit(tile_data.get_custom_data("break_particle"),to_global(tile_coords) + Vector2(32,32))
				SignalBus.broken_tile.emit(tile_coords)
				body.erase_cell(tile_coords)
				
		queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
