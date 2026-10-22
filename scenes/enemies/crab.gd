extends CharacterBody2D
var total_rotate = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$Sprite2D.rotation = total_rotate
	total_rotate += delta * 2 * PI
	if total_rotate >= 2*PI:
		total_rotate -= 2*PI
