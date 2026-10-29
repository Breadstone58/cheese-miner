extends Node2D

@onready var sprite1: AnimatedSprite2D = $Parallax2D/AnimatedSprite2D
@onready var sprite2: AnimatedSprite2D = $Parallax2D2/AnimatedSprite2D
@onready var sprite3: AnimatedSprite2D = $Parallax2D3/AnimatedSprite2D
@onready var sprite4: AnimatedSprite2D = $Parallax2D4/AnimatedSprite2D
@onready var sprite5: AnimatedSprite2D = $Parallax2D5/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite1.frame = GlobVar.biome
	sprite2.frame = GlobVar.biome
	sprite3.frame = GlobVar.biome
	sprite4.frame = GlobVar.biome
	sprite5.frame = GlobVar.biome
