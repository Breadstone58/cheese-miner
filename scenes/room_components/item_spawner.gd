extends Node2D
const ITEM_SCENE = preload("res://scenes/room_components/item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_item(location: Vector2i, state: int):
	var item = ITEM_SCENE.instantiate()
	item.state = state
	add_child(item)
	item.global_position = location
