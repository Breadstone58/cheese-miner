extends Node2D
const PARTICLE_SCENE = preload("res://scenes/break_particles.tscn")
@onready var cam: Camera2D = $CharacterBody2D/Camera2D
var scroll_down = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.spawn_particle.connect(_on_particle_spawn)
	GlobVar.transitioning = false
	var used_cells = $TileMapLayer.get_used_cells()
	
	for coords in used_cells:
		
		# Only swap if it's one of our tile sources (skips empty or other sources if any)
		var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
		var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
			
			# Replace the cell with the new source ID while keeping its shape and position
		$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Determine Scroll Lock
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 2048
	if $CharacterBody2D.position.y > 1152:
		GlobVar.transitioning = true
		cam.limit_bottom = $CharacterBody2D.position.y + scroll_down
		scroll_down += delta * 1152
		if scroll_down >= 1152:
			get_tree().change_scene_to_file("res://scenes/scroll_transition.tscn")
	else:
		cam.limit_bottom = 1152
	if Input.is_action_just_pressed("open_door_debug"):
		SignalBus.level_complete.emit()

func _on_particle_spawn(new_texture: Texture2D, spawn_position: Vector2i):
	print(spawn_position)
	var particle_instance = PARTICLE_SCENE.instantiate() as CPUParticles2D
	particle_instance.texture = new_texture
	
	# 1. Set the global position safely before entering the tree
	particle_instance.global_position = Vector2(spawn_position)
	
	# 2. Add to the tree after positioning
	add_child(particle_instance)
	
	particle_instance.restart()
