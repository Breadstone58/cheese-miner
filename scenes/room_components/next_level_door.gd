extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	SignalBus.level_complete.connect(_on_level_complete)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$CollisionShape2D.shape.size.x = 64 - $AnimatedSprite2D.frame * 2
	$CollisionShape2D.position.x = -1 * $AnimatedSprite2D.frame

func _on_level_complete():
	$AnimatedSprite2D.play()
