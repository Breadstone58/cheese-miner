extends Area2D

@onready var sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@export var state: int = 0 #0: Random Common, 1: Random Uncommon, 2: Random Rare, 3: Random Gadget, 4: Cycling Common, 5: Cycling Uncommon, 6: Cycling Rare, 7: Cycling Gadget, 8: Custom
#10: Previous Gadget, #11: Shop Item, #12: Money
@export var custom_rarity: String = ""
@export var custom_item: int = 0
var random = false
var prev_gadget = ""
var pickup_cooldown = false
var cost = 0
var money_amount = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match state:
		0:
			sprite.animation = "common"
			sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("common"))
		1:
			sprite.animation = "uncommon"
			sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("uncommon"))
		2:
			sprite.animation = "rare"
			sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("rare"))
		3:
			sprite.animation = "gadget"
			sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("gadget"))
		8,9:
			sprite.animation = custom_rarity
			sprite.frame = custom_item
		10:
			pickup_cooldown = true
			sprite.animation = "gadget"
			sprite.frame = GlobVar.gadget_change_key
			await get_tree().create_timer(3.0).timeout
			pickup_cooldown = false
		11:
			randomize()
			var rarity = randf()
			if rarity < 36.0/55.0:
				rarity = 0
			elif rarity < 45.0/55.0:
				rarity = 1
			elif rarity < 46.0/55.0:
				rarity = 2
			else:
				rarity = 3
			match rarity:
				0:
					sprite.animation = "common"
					sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("common"))
				1:
					sprite.animation = "uncommon"
					sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("uncommon"))
				2:
					sprite.animation = "rare"
					sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("rare"))
				3:
					sprite.animation = "gadget"
					sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("gadget"))
			$Price.text = "$" + str(cost)
			$Price.visible = true
		12:
			sprite.animation = "money" + str(GlobVar.biome)
			sprite.frame = 0
			sprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobVar.transitioning == true and (state < 8 or state == 12):
		queue_free()
	elif GlobVar.transitioning == true:
		state = 9
	if state == 11 and GlobVar.leaving_shop:
		queue_free()

func get_rarity():
	return sprite.animation

func get_id():
	return sprite.frame

func _on_area_entered(area: Area2D) -> void:
	if state == 11 and GlobVar.money < cost:
		return
	elif state == 11:
		GlobVar.money -= cost
	if get_rarity() == "common":
		GlobVar.inventory.append(ItemID.common[get_id()])
	elif get_rarity() == "uncommon":
		GlobVar.inventory.append(ItemID.uncommon[get_id()])
	elif get_rarity() == "rare":
		GlobVar.inventory.append(ItemID.rare[get_id()])
	elif get_rarity() == "gadget" and not pickup_cooldown:
		prev_gadget = GlobVar.gadget
		GlobVar.gadget = ItemID.gadget[get_id()]
		for key in ItemID.gadget:
			if ItemID.gadget[key] == prev_gadget:
				GlobVar.gadget_change_key = key
				break
		if GlobVar.gadget_change_key != -1:
			ItemSpawner.spawn_item(global_position,10)
	elif "money" in get_rarity():
		GlobVar.money += money_amount
	if not pickup_cooldown:
		queue_free()
