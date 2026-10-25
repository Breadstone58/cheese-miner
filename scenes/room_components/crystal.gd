extends Area2D

signal crystal_hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AnimatedSprite2D.frame = GlobVar.biome


func _on_area_entered(area: Area2D) -> void:
	if area is Bite:
		crystal_hit.emit()
