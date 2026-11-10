class_name Bite
extends Area2D
var damage: int = 5

@onready var bite_box: CollisionShape2D = $CollisionShape2D
@onready var player: CharacterBody2D = $".."
@onready var bite_sprite: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bite_box.disabled = true
	bite_sprite.visible = false	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	damage = 5 + GlobVar.exBiteDamage
	#if not bite_sprite.is_playing():
		#bite_box.disabled = true
		#bite_sprite.scale.x = player.facing
	if Input.is_action_just_pressed("bite") and not bite_sprite.is_playing() and GlobVar.playerHealth > 0:
		bite_sprite.scale.x = player.facing
		bite_box.position.x = 32 * player.facing
		bite_sprite.position.x = 16 * player.facing
		$CollisionShape2D/AnimatedSprite2D/bitefade.play("visible")
		bite_sprite.visible = true
		bite_sprite.frame = 0
		bite_sprite.play()
		bite_box.disabled = false
		await bite_sprite.animation_finished
		bite_box.disabled = true
		$CollisionShape2D/AnimatedSprite2D/bitefade.play("fade")
		await $CollisionShape2D/AnimatedSprite2D/bitefade.animation_finished
		bite_sprite.visible = false
		
	
