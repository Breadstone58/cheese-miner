extends CPUParticles2D

func _ready() -> void:
	GlobVar.blocks_broken += 1
	$SFX.play()
	finished.connect(queue_free)
	emitting = true
