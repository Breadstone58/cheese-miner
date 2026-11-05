extends CharacterBody2D

var health = 5 + 5 * floor(GlobVar.stage / 5.0)
var stunned = false
var stun_counter = 0
var unstun = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hitbox.damage = int(9 + GlobVar.stage * 1.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
