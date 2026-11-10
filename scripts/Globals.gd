extends Node

var biome = 0
var positional_biome = 0
var PlayerX = 541
var PlayerY = 1028
var transitioning = false
var stage: int = 0
var playerHealth = 100
var healthMax = 100
var shopChance = 0
var leaving_shop = false
var money = 0
var money_disp_frame = 0
var energy_disp_frame = 0
var charFacing = 1
var music_biome = -1
var levels_remaining = []

#items
var inventory = []
var gadget = ""
var exMoveSpeed = 0
var exJumps = 0
var bulletBounces = 0
var exBulletDamage = 0
var exBiteDamage = 0
var exBiteHeal = 0
var levelStartHeal = 0
var crouch_boost = 0.0
var exMaxHP = 0
var exAttackSpeed = 0

#gadget stuff
var gadget_change_key = -1
var energy = -1

#stats
var blocks_broken = 0
var enemies_killed = 0
var items = 0

var tunnel_color = {
	0 : Color("#250239"),
	1 : Color("#232741"),
	2 : Color("#3c1100"),
	3 : Color("#2C291A"),
	5 : Color(0.417, 0.417, 0.417, 1.0)
}

func count_items(item: String):
	var count = 0
	for i in inventory:
		if i == item:
			count += 1
	return count
	
func item_exists(item: String):
	if item in inventory:
		return 1
	else:
		return 0

#update items

func _process(delta: float) -> void:
	exMoveSpeed = count_items("Coffee") * 75
	exJumps = count_items("Jump_Tank")
	bulletBounces = count_items("Rubber_Bullet")
	levelStartHeal = count_items("Medkit") * 10
	exBiteHeal = count_items("Bloodlust") * 3
	exBulletDamage = count_items("Diamond") * 2
	crouch_boost = 200.0 + count_items("Spring_Boots") * 150.0
	healthMax = 100 + count_items("Magic_Cheese") * 20
	exAttackSpeed = count_items("Drill_Oil") / -30.0
	items = inventory.size()

func _ready() -> void:
	SignalBus.enemy_killed.connect(_on_kill)
	SignalBus.grub_killed.connect(_on_kill)

func _on_kill():
	enemies_killed += 1

func reset_to_default() -> void:
	biome = 0
	positional_biome = 0
	PlayerX = 541
	PlayerY = 1028
	transitioning = false
	stage = 0
	playerHealth = 100
	healthMax = 100
	shopChance = 0
	leaving_shop = false
	money = 0
	money_disp_frame = 0
	energy_disp_frame = 0
	charFacing = 1
	music_biome = -1
	levels_remaining.clear()

	# Items
	inventory.clear()
	gadget = ""
	exMoveSpeed = 0
	exJumps = 0
	bulletBounces = 0
	exBulletDamage = 0
	exBiteDamage = 0
	exBiteHeal = 0
	levelStartHeal = 0
	crouch_boost = 0.0
	exMaxHP = 0
	exAttackSpeed = 0

	# Gadget stuff
	gadget_change_key = -1
	energy = -1

	# Stats
	blocks_broken = 0
	enemies_killed = 0
	
	ArcadeMode.arcade_mode = false
