extends Node2D
const PARTICLE_SCENE = preload("res://scenes/room_components/break_particles.tscn")
@onready var cam: Camera2D = $CharacterBody2D/Camera2D
var scroll_down = 0
var top_locked = false
var level_complete = false
var break_goal = 0
var tiles_left = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.spawn_particle.connect(_on_particle_spawn)
	var used_cells = $TileMapLayer.get_used_cells()
	for coords in used_cells:
		var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
		var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
		$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
	if GlobVar.biome == 2:
		for coords in used_cells:
			var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
			randomize()
			if randf() < 0.15 and $TileMapLayer.get_cell_tile_data(coords).get_custom_data("breakable"):
				$TileMapLayer.set_cell(coords, 4, atlas_coords, alternative_tile)
	used_cells = $TileMapLayer.get_used_cells()
	var broken_count = 0
	for coords in used_cells:
		var tile_data = $TileMapLayer.get_cell_tile_data(coords)
		if tile_data and tile_data.get_custom_data("breakable"):
			broken_count += 1
	break_goal = floori(broken_count * clamp(0.5 + 0.1 * floori(GlobVar.stage/5.0),0,1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Determine Scroll Lock
	cam.limit_left = 0
	cam.limit_right = 2048
	if $CharacterBody2D.position.y >= 0:
		GlobVar.transitioning = false
		SignalBus.level_goal.emit("Break ("+str(tiles_left)+") More Cheese!")
	if top_locked == false:
		cam.limit_top = max($CharacterBody2D.position.y - 576,cam.limit_top)
	else:
		cam.limit_top = 0
	
	if $CharacterBody2D.position.y - 576 > 0:
		top_locked = true
	
	if $CharacterBody2D.position.y > 1152:
		GlobVar.transitioning = true
		SignalBus.level_goal.emit("")
		cam.limit_bottom = $CharacterBody2D.position.y + scroll_down
		scroll_down += delta * 1152
		if scroll_down >= 1152:
			get_tree().change_scene_to_file("res://scenes/scroll_transition.tscn")
	else:
		cam.limit_bottom = 1152
		
	var used_cells = $TileMapLayer.get_used_cells()
	var broken_count = 0
	for coords in used_cells:
		var tile_data = $TileMapLayer.get_cell_tile_data(coords)
		if tile_data and tile_data.get_custom_data("breakable"):
			broken_count += 1
	tiles_left = clamp(broken_count - break_goal,0,broken_count)
	
	if tiles_left == 0 and not level_complete:
		SignalBus.level_complete.emit()
		level_complete = true

func _on_particle_spawn(new_texture: Texture2D, spawn_position: Vector2i):
	var particle_instance = PARTICLE_SCENE.instantiate() as CPUParticles2D
	particle_instance.texture = new_texture
	
	# 1. Set the global position safely before entering the tree
	particle_instance.global_position = Vector2(spawn_position)
	
	# 2. Add to the tree after positioning
	add_child(particle_instance)
	
	particle_instance.restart()
