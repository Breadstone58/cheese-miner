extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var used_cells = $TileMapLayer.get_used_cells()
	for coords in used_cells:
		var atlas_coords = $TileMapLayer.get_cell_atlas_coords(coords)
		var alternative_tile = $TileMapLayer.get_cell_alternative_tile(coords)
		$TileMapLayer.set_cell(coords, GlobVar.biome, atlas_coords, alternative_tile)
	var new_biome = randi_range(0,1)
	used_cells = $TileMapLayer2.get_used_cells()
	for coords in used_cells:
		var atlas_coords = $TileMapLayer2.get_cell_atlas_coords(coords)
		var alternative_tile = $TileMapLayer2.get_cell_alternative_tile(coords)
		$TileMapLayer2.set_cell(coords, new_biome, atlas_coords, alternative_tile)
	GlobVar.biome = new_biome


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $CharacterBody2D.position.y >= 6848:
		get_tree().change_scene_to_file("res://scenes/rooms/room_template.tscn")
