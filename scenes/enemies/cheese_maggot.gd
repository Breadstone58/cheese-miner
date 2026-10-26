extends CharacterBody2D

@export var speed: float = 700.0
@export var fall_speed: float = 1700.0
@export var launch_speed: float = 1300.0
@export var move_direction: Vector2 = Vector2.UP
var facing: int = 1

var health = 5
var status = 0

func _ready() -> void:
	$Hitbox.damage = 1 + GlobVar.stage
	var rand_angle = randf_range(PI/4.0,3*PI/4.0)
	move_direction = Vector2(cos(rand_angle),-sin(rand_angle)).normalized()
	move_direction *= Vector2(1.0,2.0)

func _physics_process(delta: float) -> void:
	match status:
		0:
			$AnimatedSprite2D.animation = "spin"
			velocity = move_direction * launch_speed * delta
			velocity.y += fall_speed * delta
			launch_speed = clamp(launch_speed - 500.0 * delta,0,INF)
			$AnimatedSprite2D.rotate(2*PI*delta)
			var collision = move_and_collide(velocity)
			if collision:
				velocity = Vector2.ZERO
				status = 1
			$CollisionMoving.disabled = true
			$CollisionSpinning.disabled = false
			$Hurtbox/CollisionMoving.disabled = true
			$Hurtbox/CollisionSpinning.disabled = false
			$Hitbox/CollisionMoving.disabled = true
			$Hitbox/CollisionSpinning.disabled = false
		1:
			$AnimatedSprite2D.rotation = 0
			$AnimatedSprite2D.animation = "movement"
			$AnimatedSprite2D.play()
			if not is_on_floor():
				velocity.y += fall_speed * delta
			velocity.x = speed * delta * facing
			move_and_slide()
			$CollisionMoving.disabled = false
			$CollisionSpinning.disabled = true
			$Hurtbox/CollisionMoving.disabled = false
			$Hurtbox/CollisionSpinning.disabled = true
			$Hitbox/CollisionMoving.disabled = false
			$Hitbox/CollisionSpinning.disabled = true
			if $FacingCast.is_colliding():
				scale.x *= -1
				facing *= -1

func _process(delta: float) -> void:
	pass

func damage(amount: int,source: String):
	health -= amount
	if health <= 0 and source == "Bite":
		SignalBus.bite_death.emit(-5)
		queue_free()
	if health <= 0:
		queue_free()
	modulate = Color(255,0,0,255)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1,1)
	

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Bite:
		damage(area.damage,"Bite")
