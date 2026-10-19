extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT

func setup(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
func _on_body_entered(body: Node2D) -> void:
	queue_free()
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
