extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func transition_to(target_scene: String, duration: float = 0.5) -> void:
	# 1. Start fully transparent black
	color_rect.color = Color(0, 0, 0, 0)
	
	# 2. Fade TO solid black
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 1.0), duration)
	await tween.finished

	# 3. CRITICAL: Force Godot to draw the fully black screen before swapping scenes
	await RenderingServer.frame_post_draw

	# 4. Change the scene safely while the screen is locked solid black
	get_tree().change_scene_to_file(target_scene)
	
	# Wait one frame for the new scene to instantiate its nodes
	await get_tree().process_frame

	# 5. Fade FROM solid black back to transparent
	tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 0.0), duration)
	await tween.finished
