extends Node2D
const PARTICLE_SCENE = preload("res://scenes/room_components/break_particles.tscn")
@onready var cam: Camera2D = $CharacterBody2D/Camera2D
var scroll_down = 0
var top_locked = false
var level_complete = false
var refresh_cost = clamp(GlobVar.stage * 3,1,INF)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.spawn_particle.connect(_on_particle_spawn)
	$Crystal.crystal_hit.connect(_on_refresh)
	var used_cells = $TileMapLayer.get_used_cells()
	for coords in used_cells:
		var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
		var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
		$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Determine Scroll Lock
	cam.limit_left = 0
	cam.limit_right = 2048
	if $CharacterBody2D.position.y >= 0:
		GlobVar.transitioning = false
		SignalBus.level_goal.emit("")
	if top_locked == false:
		cam.limit_top = max($CharacterBody2D.position.y - 576,cam.limit_top)
	else:
		cam.limit_top = 0
	
	if $CharacterBody2D.position.y - 576 > 0:
		top_locked = true
	
	if $CharacterBody2D.position.y > 1152:
		GlobVar.transitioning = true
		GlobVar.leaving_shop = false
		SignalBus.level_goal.emit("")
		cam.limit_bottom = $CharacterBody2D.position.y + scroll_down
		scroll_down += delta * 1152
		if scroll_down >= 1152:
			get_tree().change_scene_to_file("res://scenes/scroll_transition.tscn")
	else:
		cam.limit_bottom = 1152
	$Crystal/RefreshCost.text = "$" + str(refresh_cost)
	
func _on_particle_spawn(new_texture: Texture2D, spawn_position: Vector2i):
	var particle_instance = PARTICLE_SCENE.instantiate() as CPUParticles2D
	particle_instance.texture = new_texture
	
	# 1. Set the global position safely before entering the tree
	particle_instance.global_position = Vector2(spawn_position)
	
	# 2. Add to the tree after positioning
	add_child(particle_instance)
	
	particle_instance.restart()

func _on_refresh():
	if GlobVar.money >= refresh_cost:
		GlobVar.money -= refresh_cost
		refresh_cost = int(ceil(refresh_cost * 1.5))
		SignalBus.refresh_shop.emit()
		var tween = create_tween()
		tween.tween_property($Crystal/RefreshIcon,"rotation",$Crystal/RefreshIcon.rotation + PI, 0.3)
