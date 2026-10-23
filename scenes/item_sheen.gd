extends TileMapLayer

@onready var block_tiles: TileMapLayer = $".."
var item_tiles = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.broken_tile.connect(_on_tile_broken)
	var atlas_source = tile_set.get_source(0) as TileSetAtlasSource
	for i in range(1,32):
		atlas_source.set_tile_animation_frame_duration(Vector2i(0,0),i,(53.0 / 128000.0) * (i * i) - (53.0 / 4000.0) * i + 0.131)
	var used_cells = block_tiles.get_used_cells()
	for coords in used_cells:
		var tile_data = block_tiles.get_cell_tile_data(coords)
		if tile_data.get_custom_data("breakable") and randf() < 1:
			set_cell(coords,0,Vector2i(0,0))
			item_tiles.append(coords)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_broken(coords: Vector2i):
	if coords in item_tiles:
		item_tiles.erase(coords)
		erase_cell(coords)
		randomize()
		var rarity = randf()
		if rarity < 36.0/55.0:
			rarity = 0
		elif rarity < 45.0/55.0:
			rarity = 1
		elif rarity < 46.0/55.0:
			rarity = 2
		else:
			rarity = 2
		ItemSpawner.spawn_item(to_global(map_to_local(coords)),int(rarity))
