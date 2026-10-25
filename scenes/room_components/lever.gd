extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = "off"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area is Bite and $AnimatedSprite2D.animation == "off":
		$AnimatedSprite2D.animation = "on"
		SignalBus.level_complete.emit()
