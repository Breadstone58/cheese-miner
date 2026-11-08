extends AnimatedSprite2D

const EXPLOSION = preload("res://scenes/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$"../Cat".killed.connect(_on_kill)
	
func _on_kill(death_area: Vector2):
	position = death_area
	$Body.frame = $"../Cat".body_frame
	visible = true
	
	await get_tree().create_timer(3.0).timeout
	
	var explosion_count = 1
	var start_time = Time.get_ticks_msec()
	var total_duration_ms = 4000.0
	
	while Time.get_ticks_msec() - start_time < total_duration_ms:
		await get_tree().process_frame
		explosion_count += 1
		
		if explosion_count % 3 == 0:
			var explosion = EXPLOSION.instantiate()
			explosion.global_position = position - Vector2(randi_range(-224, 224), randi_range(-128, 128))
			get_tree().current_scene.add_child(explosion)
	
	await get_tree().create_timer(0.222).timeout
	var explosionBig = EXPLOSION.instantiate()
	explosionBig.global_position = position
	explosionBig.z_index = 1
	explosionBig.scale = Vector2(6.25,6.25)
	get_tree().current_scene.add_child(explosionBig)
	ItemSpawner.spawn_item(Vector2(global_position.x,clamp(global_position.y,768,1088)),2)
	ItemSpawner.spawn_money(Vector2(global_position.x,clamp(global_position.y,768,1088)),clamp(randi_range(2 * GlobVar.stage,3 * GlobVar.stage),1,INF))
	queue_free()
