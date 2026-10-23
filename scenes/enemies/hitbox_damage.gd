class_name Hitbox
extends Area2D

@export var damage: int = 10

func _process(delta: float) -> void:
	if "stunned" in get_parent() and get_parent().stunned:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
