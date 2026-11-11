extends Node2D
var visibility_toggle = 0 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("bouncy")
	save_shit()
	$RichTextLabel.text = "Highest Stage: " + str(GlobVar.stage) + "\nBlocks Broken: " + str(GlobVar.blocks_broken) + "\nKills: " + str(GlobVar.enemies_killed) + "\nItems Gathered: " + str(GlobVar.items) + "\n\n\n<Press Start>"
	InputMap.action_add_event("fn", (func(): var e = InputEventKey.new(); e.keycode = KEY_ENTER; return e).call())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visibility_toggle += delta
	if visibility_toggle >= 0.5:
		visibility_toggle = 0
		$RichTextLabel/ColorRect.visible = not $RichTextLabel/ColorRect.visible
	
	if Input.is_action_just_pressed("fn"):
		GlobVar.reset_to_default()
		SceneTransitions.transition_to("res://scenes/rooms/title.tscn",0.5)
		

func save_shit():
	if GlobVar.stage > GlobVar.high_score[0]: # deepest layer, blocks broken, enemies killed, items
		GlobVar.high_score = [GlobVar.stage, GlobVar.blocks_broken,GlobVar.enemies_killed,GlobVar.items]
		GlobVar.save()
		print("hey it fkn.. it did the thing")
