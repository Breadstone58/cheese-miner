extends Node2D

var rand_level = 0
var valid_biome = false
var new_biome = 0
var going_shop = false
var force_new_biome = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobVar.leaving_shop = false
	if randf() < GlobVar.shopChance:
		going_shop = true
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
	else:
		if GlobVar.stage == 4:
			GlobVar.shopChance = 1
		if GlobVar.stage >= 5 and GlobVar.shopChance == 0:
			force_new_biome = true 
		if GlobVar.stage >= 5:
			GlobVar.shopChance += 0.1
		rand_level = randi_range(0,3)
		$CharacterBody2D.heal(GlobVar.levelStartHeal)
		GlobVar.transitioning = true
		while not valid_biome:
			randomize()
			if not force_new_biome:
				if randf() > (2.0/3.0):
					new_biome = randi_range(0,3)
				else:
					new_biome = GlobVar.biome
				if rand_level in LevelBiomes.lvl:
					if new_biome == LevelBiomes.lvl[rand_level]:
						valid_biome = true
				else:
					valid_biome = true
			else:
				new_biome = randi_range(0,3)
				if new_biome != GlobVar.biome:
					valid_biome = true
		if GlobVar.stage == 0:
			new_biome = randi_range(3,3)
			GlobVar.biome = new_biome
			GlobVar.positional_biome = new_biome
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
		GlobVar.biome = new_biome
		GlobVar.stage += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $CharacterBody2D.position.y >= 6848:
		if going_shop:
			get_tree().change_scene_to_file("res://scenes/rooms/shop.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/rooms/room_"+str(rand_level)+".tscn")

func _on_next_biome_area_entered(area: Area2D) -> void:
		GlobVar.positional_biome = new_biome
