extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().current_scene.name == "shop":
		$BlueBiome.volume_db = clamp($BlueBiome.volume_db - delta * 80, -80, 0)
		$GreenBiome.volume_db = clamp($GreenBiome.volume_db - delta * 80,-80,0)
	else:
		$BlueBiome.volume_db = clamp($BlueBiome.volume_db + delta * 80 * (1 if GlobVar.music_biome == 1 else -1),-80.0,0.0)
		$GreenBiome.volume_db = clamp($GreenBiome.volume_db + delta * 80 * (1 if GlobVar.music_biome == 3 else -1),-80.0,0)
