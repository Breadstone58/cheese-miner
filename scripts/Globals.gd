extends Node

var biome = 0
var positional_biome = 0
var PlayerX = 1024
var transitioning = false
var stage: int = 0
var playerHealth = 100
var healthMax = 100
var shopChance = 0
var leaving_shop = false
var money = 100
var money_disp_frame = 0
var energy_disp_frame = 0

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

#gadget stuff
var gadget_change_key = -1
var energy = -1


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
	crouch_boost = 200.0 + count_items("Spring_Boots") * 300.0
	healthMax = 100.0 + count_items("Magic_Cheese") * 20
