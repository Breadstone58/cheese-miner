extends Area2D

@onready var sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@export var state: int = 0 #0: Random Common, 1: Random Uncommon, 2: Random Rare, 3: Random Gadget, 4: Cycling Common, 5: Cycling Uncommon, 6: Cycling Rare, 7: Cycling Gadget, 8: Custom
@export var custom_rarity: String = ""
@export var custom_item: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match state:
		0:
			sprite.animation = "common"
			sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("common"))
		8,9:
			sprite.animation = custom_rarity
			sprite.frame = custom_item


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobVar.transitioning == true and state != 8:
		queue_free()
	elif GlobVar.transitioning == true:
		state = 9

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
