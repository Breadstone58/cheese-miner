extends Node

var biome = 0
var PlayerX = 1024
var transitioning = false
var stage = 0
var playerHealth = 100
var healthMax = 100

#items
var inventory = []
var exMoveSpeed = 0
var exJumps = 0

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
