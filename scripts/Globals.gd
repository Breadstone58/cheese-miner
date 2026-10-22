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
		if i.to_lower() == item.to_lower():
			count += 1
	return count
