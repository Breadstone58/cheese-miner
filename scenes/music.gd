extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.boss_music.connect(_on_boss_music)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().current_scene:
		if get_tree().current_scene.name == "shop":
			$YellowBiome.volume_db = clamp($YellowBiome.volume_db - delta * 80,-80,0)
			$BlueBiome.volume_db = clamp($BlueBiome.volume_db - delta * 80, -80, 0)
			$RedBiome.volume_db = clamp($RedBiome.volume_db - delta * 80,-80,0)
			$GreenBiome.volume_db = clamp($GreenBiome.volume_db - delta * 80,-80,0)
			$Title.volume_db = clamp($Title.volume_db - delta * 80,-80,0)
			$Shop.volume_db = clamp($Shop.volume_db + delta * 80,-80,7)
		elif "Boss" in get_tree().current_scene.name:
			$YellowBiome.volume_db = clamp($YellowBiome.volume_db - delta * 80,-80,0)
			$BlueBiome.volume_db = clamp($BlueBiome.volume_db - delta * 80, -80, 0)
			$RedBiome.volume_db = clamp($RedBiome.volume_db - delta * 80,-80,0)
			$GreenBiome.volume_db = clamp($GreenBiome.volume_db - delta * 80,-80,0)
			$Title.volume_db = clamp($Title.volume_db - delta * 80,-80,0)
			$Shop.volume_db = clamp($Shop.volume_db - delta * 80,-80,0)
		else:
			$YellowBiome.volume_db = clamp($YellowBiome.volume_db + delta * 80 * (1 if GlobVar.music_biome == 0 else -1),-80.0,0.0)
			$BlueBiome.volume_db = clamp($BlueBiome.volume_db + delta * 80 * (1 if GlobVar.music_biome == 1 else -1),-80.0,0.0)
			$RedBiome.volume_db = clamp($RedBiome.volume_db + delta * 80 * (1 if GlobVar.music_biome == 2 else -1),-80.0,0)
			$GreenBiome.volume_db = clamp($GreenBiome.volume_db + delta * 80 * (1 if GlobVar.music_biome == 3 else -1),-80.0,0)
			$Title.volume_db = clamp($Title.volume_db + delta * 80 * (1 if GlobVar.music_biome == 5 else -1),-80.0,0)
			$Shop.volume_db = clamp($Shop.volume_db + delta * -80,-80,0)
			$Boss.stop()

func _on_boss_music(state: bool):
	if state:
		$Boss.play()
	else:
		$Boss.stop()
