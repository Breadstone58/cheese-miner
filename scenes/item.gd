extends Area2D

@onready var sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_rarity():
	return sprite.animation

func get_id():
	return sprite.frame

func _on_area_entered(area: Area2D) -> void:
	if get_rarity() == "common":
		GlobVar.inventory.append(ItemID.common[get_id()])
	elif get_rarity() == "uncommon":
		GlobVar.inventory.append(ItemID.uncommon[get_id()])
	else:
		GlobVar.inventory.append(ItemID.rare[get_id()])
	queue_free()
