extends Node2D

var rand_level = 0
const LEVEL_COUNT = 19
var valid_biome = false
var new_biome = 0
var going_shop = false
var force_new_biome = false
var prev_biome = GlobVar.biome
var going_boss = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobVar.leaving_shop = false
	GlobVar.lowestCostItem = INF
	if GlobVar.stage == 0 or GlobVar.levels_remaining.size() == 0:
		force_new_biome = true
		GlobVar.levels_remaining = range(0,LEVEL_COUNT+1)
		if GlobVar.stage == 0:
			for level in GlobVar.levels_remaining.duplicate():
				if level in LevelBiomes.hard:
					GlobVar.levels_remaining.erase(level)
	print(GlobVar.levels_remaining)
	if randf() < GlobVar.shopChance:
		going_shop = true
		$Shop_Sign.visible = true
		GlobVar.shopChance = 0
		new_biome = GlobVar.biome
		var used_cells = $TileMapLayer.get_used_cells()
		for coords in used_cells:
			var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
			$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
		used_cells = $TileMapLayer2.get_used_cells()
		for coords in used_cells:
			var atlas_coords = $TileMapLayer2.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer2.get_cell_alternative_tile(coords)
			$TileMapLayer2.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
	elif (GlobVar.stage + 1) % 10 == 0:
		going_boss = true
		new_biome = GlobVar.biome
		var used_cells = $TileMapLayer.get_used_cells()
		for coords in used_cells:
			var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
			$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
		used_cells = $TileMapLayer2.get_used_cells()
		for coords in used_cells:
			var atlas_coords = $TileMapLayer2.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer2.get_cell_alternative_tile(coords)
			$TileMapLayer2.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
		GlobVar.stage += 1
	else:
		if GlobVar.stage == 4:
			GlobVar.shopChance = 1
		if (GlobVar.stage >= 5 and GlobVar.shopChance == 0 and not going_boss) or GlobVar.leaving_boss:
			force_new_biome = true 
			GlobVar.leaving_boss = false
		if GlobVar.stage >= 5:
			GlobVar.shopChance += 0.1
		rand_level = GlobVar.levels_remaining.pick_random()

		$CharacterBody2D.heal(GlobVar.levelStartHeal)
		GlobVar.transitioning = true
		while not valid_biome:
			randomize()
			if not force_new_biome:
				if randf() > (2.0/3.0):
					new_biome = randi_range(0, 3 if GlobVar.stage >= 5 else 0)
				else:
					new_biome = GlobVar.biome
				if rand_level in LevelBiomes.lvl:
					if new_biome == LevelBiomes.lvl[rand_level]:
						valid_biome = true
					else:
						GlobVar.levels_remaining.erase(rand_level)
						rand_level = GlobVar.levels_remaining.pick_random()
				else:
					valid_biome = true
			else:
				new_biome = randi_range(0,3 if GlobVar.stage >= 5 else 0)
				if new_biome != GlobVar.biome:
					if rand_level in LevelBiomes.lvl:
						if new_biome == LevelBiomes.lvl[rand_level]:
							valid_biome = true
						else:
							rand_level = GlobVar.levels_remaining.pick_random()
					else:
						valid_biome = true
		var used_cells = $TileMapLayer.get_used_cells()
		for coords in used_cells:
			var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
			$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
		
		
		used_cells = $TileMapLayer2.get_used_cells()
		for coords in used_cells:
			var atlas_coords = $TileMapLayer2.get_cell_atlas_coords(coords)
			var alternative_tile = $TileMapLayer2.get_cell_alternative_tile(coords)
			$TileMapLayer2.set_cell(coords, new_biome, atlas_coords, alternative_tile)
		$Tunnel2.color = GlobVar.tunnel_color[new_biome]
		if GlobVar.stage >= 1 and GlobVar.biome != new_biome:
			GlobVar.levels_remaining = range(0,LEVEL_COUNT+1)
		GlobVar.biome = new_biome
		GlobVar.stage += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Tunnel.color = GlobVar.tunnel_color[prev_biome]
	GlobVar.music_biome = new_biome
	if $CharacterBody2D.position.y >= 6848:
		if going_shop:
			get_tree().change_scene_to_file("res://scenes/rooms/shop.tscn")
		elif going_boss:
			get_tree().change_scene_to_file("res://scenes/rooms/boss_"+str(randi_range(0,0))+".tscn")
		else:
			GlobVar.levels_remaining.erase(rand_level)
			get_tree().change_scene_to_file("res://scenes/rooms/room_"+str(rand_level)+".tscn")

func _on_next_biome_area_entered(area: Area2D) -> void:
		GlobVar.positional_biome = new_biome
