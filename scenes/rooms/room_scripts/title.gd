extends Node2D
const PARTICLE_SCENE = preload("res://scenes/room_components/break_particles.tscn")
@onready var cam: Camera2D = $CharacterBody2D/Camera2D
var scroll_down = 0
var level_complete = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.spawn_particle.connect(_on_particle_spawn)
	GlobVar.biome = 5
	GlobVar.positional_biome = 5
	GlobVar.music_biome = 5
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Determine Scroll Lock
	cam.limit_left = 0
	cam.limit_right = 2048
	cam.limit_top = 0
	$Tunnel2.color = GlobVar.tunnel_color[5]
	
	
	if $CharacterBody2D.position.y > 1152:
		GlobVar.transitioning = true
		SignalBus.level_goal.emit("")
		cam.limit_bottom = $CharacterBody2D.position.y + scroll_down
		scroll_down += delta * 1152
		if scroll_down >= 1152:
			get_tree().change_scene_to_file("res://scenes/scroll_transition.tscn")
	else:
		cam.limit_bottom = 1152
		

func _on_particle_spawn(new_texture: Texture2D, spawn_position: Vector2i):
	var particle_instance = PARTICLE_SCENE.instantiate() as CPUParticles2D
	particle_instance.texture = new_texture
	
	# 1. Set the global position safely before entering the tree
	particle_instance.global_position = Vector2(spawn_position)
	
	# 2. Add to the tree after positioning
	add_child(particle_instance)
	
	particle_instance.restart()


func _on_crystal_hit() -> void:
	if not level_complete:
		$TileMapLayer.set_cell(Vector2i(15,15),0,Vector2i(0,0))
		$TileMapLayer.set_cell(Vector2i(16,15),0,Vector2i(2,0))
		$TileMapLayer.set_cell(Vector2i(14,16),0,Vector2i(0,0))
		$TileMapLayer.set_cell(Vector2i(15,16),0,Vector2i(4,1))
		$TileMapLayer.set_cell(Vector2i(16,16),0,Vector2i(3,1))
		$TileMapLayer.set_cell(Vector2i(17,16),0,Vector2i(2,0))
		$TileMapLayer.set_cell(Vector2i(15,17),0,Vector2i(1,1))
		$TileMapLayer.set_cell(Vector2i(16,17),0,Vector2i(1,1))
		level_complete = true
	
