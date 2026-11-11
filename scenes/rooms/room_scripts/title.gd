extends Node2D
const PARTICLE_SCENE = preload("res://scenes/room_components/break_particles.tscn")
@onready var cam: Camera2D = $CharacterBody2D/Camera2D
var scroll_down = 0
var scroll_down_title = 0
var level_complete = false
var game_start = false
var trigger_arcade_mode = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobVar.high_score == [0,0,0,0]:
		$ControlHigh/HighScore.visible = false
		$Instructions/RESET.visible = false
	cam.limit_top = -1152
	cam.limit_bottom = 0
	SignalBus.spawn_particle.connect(_on_particle_spawn)
	GlobVar.biome = 5
	GlobVar.positional_biome = 5
	GlobVar.music_biome = 5
	for action in InputMap.get_actions():
		InputMap.action_erase_events(action)
	InputMap.action_add_event("fn", (func(): var e = InputEventJoypadButton.new(); e.button_index = JOY_BUTTON_START; return e).call())
	InputMap.action_add_event("fn", (func(): var e = InputEventKey.new(); e.keycode = KEY_ENTER; return e).call())
	InputMap.action_add_event("arcade_mode", (func(): var e = InputEventJoypadButton.new(); e.button_index = JOY_BUTTON_BACK; return e).call())
	$ControlHigh/HighScore.text = ("~ PERSONAL BEST ~" 
	+ "\nHighest Stage: " 
	+ str(GlobVar.high_score[0]) 
	+ "\nBlocks Broken: " 
	+ str(GlobVar.high_score[1]) 
	+ "\nKills: " + str(GlobVar.high_score[2]) 
	+ "\nItems Gathered: " + str(GlobVar.high_score[3])
	)
	 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Determine Scroll Lock
	cam.limit_left = 0
	cam.limit_right = 2048
	
	$Tunnel2.color = GlobVar.tunnel_color[5]
	
	if game_start:
		if $CharacterBody2D.position.y > 1152:
			GlobVar.transitioning = true
			SignalBus.level_goal.emit("")
			cam.limit_bottom = $CharacterBody2D.position.y + scroll_down
			scroll_down += delta * 1152
			if scroll_down >= 1152:
				get_tree().change_scene_to_file("res://scenes/scroll_transition.tscn")
		else: # oh ok this is the thing that makes it go down
			#cam.limit_bottom = min(cam.limit_bottom + delta * 1152 * 0.5,1152)
			#cam.limit_top = cam.limit_bottom - 1152
			pass
	else:
		if Input.is_action_just_pressed("fn"):
			scroll_title()
		if Input.is_action_just_pressed("arcade_mode"):
			trigger_arcade_mode = true
			scroll_title()

func _on_particle_spawn(new_texture: Texture2D, spawn_position: Vector2i):
	var particle_instance = PARTICLE_SCENE.instantiate() as CPUParticles2D
	particle_instance.texture = new_texture
	
	# 1. Set the global position safely before entering the tree
	particle_instance.global_position = Vector2(spawn_position)
	
	# 2. Add to the tree after positioning
	add_child(particle_instance)
	
	particle_instance.restart()

func _on_crystal_hit_2() -> void:
	$Instructions/FULLCONTROLS.visible = true
	$Instructions/CONTROLS.visible = false
	
func _on_save_crystal_save_hit() -> void:
	GlobVar.high_score=[0,0,0,0]
	GlobVar.save()
	$ControlHigh/HighScore.text = ("~ PERSONAL BEST ~" 
	+ "\nHighest Stage: " 
	+ str(GlobVar.high_score[0]) 
	+ "\nBlocks Broken: " 
	+ str(GlobVar.high_score[1]) 
	+ "\nKills: " + str(GlobVar.high_score[2]) 
	+ "\nItems Gathered: " + str(GlobVar.high_score[3])
	)

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
		
		$TileMapLayer.set_cell(Vector2i(20,16), 0, Vector2i(5,5))
		$TileMapLayer.set_cell(Vector2i(21,16), 0, Vector2i(3,5))
		$TileMapLayer.set_cell(Vector2i(22,16), 0, Vector2i(3,5))
		$TileMapLayer.set_cell(Vector2i(23,16), 0, Vector2i(3,5))
		$TileMapLayer.set_cell(Vector2i(24,16), 0, Vector2i(6,5))
		level_complete = true
		$Instructions/SHOOT.visible = true
		$Instructions/CJ.visible = true
		$Instructions/CROUCH.visible = false
		
	
func scroll_title():
	var tween = create_tween().set_parallel(true) # set parallel makes the 2 tweens happen at the same time which is cool and awesome
	game_start = true
	tween.tween_property(cam, "limit_bottom", 1152, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cam, "limit_top", 0, 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	InputMap.load_from_project_settings()
	if trigger_arcade_mode:
		ArcadeMode.arcade_mode = true
		#$Instructions/Jump.frame = 1
		#$Instructions/Crouch.frame = 1
		#$Instructions/Bite.frame = 1
		$Instructions/JUMP.text = "(Y)JUMP"
		$Instructions/CROUCH.text = "(B)CROUCH"
		$Instructions/SHOOT.text = "(X) SHOOT"
		$Instructions/BITE.text = "(L2) BITE"
		$Instructions/CJ.text = "(Y)+(B)\nCROUCH\nJUMP"
