extends Node2D

@onready var sprite1: AnimatedSprite2D = $Parallax2D/AnimatedSprite2D
@onready var sprite2: AnimatedSprite2D = $Parallax2D2/AnimatedSprite2D
@onready var sprite3: AnimatedSprite2D = $Parallax2D3/AnimatedSprite2D
@onready var sprite4: AnimatedSprite2D = $Parallax2D4/AnimatedSprite2D
@onready var sprite5: AnimatedSprite2D = $Parallax2D5/AnimatedSprite2D
@onready var sprite6: AnimatedSprite2D = $Parallax2D6/AnimatedSprite2D
@onready var sprite7: AnimatedSprite2D = $Parallax2D7/AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	sprite1.play()
	sprite5.play()
	if get_tree().current_scene.name == "Title":
		$Parallax2D2.scroll_scale.y = 1.0
		$Parallax2D3.scroll_scale.y = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite1.animation = str(GlobVar.biome)
	sprite2.animation = str(GlobVar.biome)
	sprite3.animation = str(GlobVar.biome)
	sprite4.animation = str(GlobVar.biome)
	sprite5.animation = str(GlobVar.biome)
	sprite6.animation = str(GlobVar.biome)
	sprite7.animation = str(GlobVar.biome)
