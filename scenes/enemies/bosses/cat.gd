class_name Cat
extends Node2D

@onready var head: AnimatedSprite2D = $Head
@onready var left_hand: AnimatedSprite2D = $"Left Hand"
@onready var right_hand: AnimatedSprite2D = $"Right Hand"

signal killed
const CRAB_SCENE = preload("res://scenes/enemies/crab.tscn")


var track = "intro" :
	set(value):
		track = value
		play_animation()

var hands_left = 2
var left_hand_alive = true
var right_hand_alive = true
var left_hand_health = GlobVar.stage * 10
var right_hand_health = GlobVar.stage * 10
var body_frame = 0

var attack_list = ["paw_slam","side_sweep","floor_slam",]
var paw_slamming = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GlobVar.stage = 15 if GlobVar.stage < 15 else GlobVar.stage
	play_animation()
	$"Left Hand/Hitbox".damage = GlobVar.stage
	$"Right Hand/Hitbox".damage = GlobVar.stage
	left_hand_health = GlobVar.stage * 10
	right_hand_health = GlobVar.stage * 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Head.animation == "intro" and $Head.frame < 7:
		pass
	elif $Head.animation == "intro" and $Head.frame == 7:
		#await get_tree().create_timer(1.0).timeout
		$Head.play("idle")
		$Head/Body.play("idle")
		SignalBus.boss_music.emit(true)
		track = "idle"
	else:
		watch_target()
		if not is_instance_valid(left_hand) or not left_hand_alive:
			left_hand = $DestroyedHand
			left_hand_alive = false
			hands_left = 1
		if not is_instance_valid(right_hand) or not right_hand_alive:
			right_hand = $DestroyedHand
			right_hand_alive = false
			hands_left = 1
		if not (left_hand_alive or right_hand_alive):
			hands_left = 0
			if track != "stunned":
				track = "stunned"
				$Head.play("stun")
				$Head/Body.stop()
				body_frame = $Head/Body.frame
		else:
			if paw_slamming == 1:
				left_hand.position = left_hand.position.move_toward(Vector2(GlobVar.PlayerX,144.0), 700*delta)
				left_hand.z_index = 1
			elif paw_slamming == 2:
				right_hand.position = right_hand.position.move_toward(Vector2(GlobVar.PlayerX,144.0), 700*delta)
				right_hand.z_index = 1
			else:
				left_hand.z_index = 0
				right_hand.z_index = 0

	

func play_animation():
	match track:
		"intro":
			pass
		"idle":
			var tweenH = create_tween()
			var tweenL = create_tween()
			var tweenR = create_tween()
			var idles = randi_range(2,4)
			var idle_speed = 0.375 * hands_left
			
			
			tweenH.set_loops(idles)
			tweenH.tween_property(head,"position",Vector2(1024.0,576.0 + 32.0),idle_speed)
			tweenH.tween_property(head,"position",Vector2(1024.0,576.0 - 32.0),idle_speed)
			
			tweenL.set_loops(idles)
			tweenL.tween_property(left_hand,"position",Vector2(512.0 - 32.0,768.0),idle_speed)
			tweenL.parallel().tween_property(left_hand,"rotation_degrees",0.0,idle_speed)
			tweenL.tween_property(left_hand,"position",Vector2(512.0 + 32.0,768.0),idle_speed)
			
			tweenR.set_loops(idles)
			tweenR.tween_property(right_hand,"position",Vector2(1536.0 + 32.0,768.0),idle_speed)
			tweenR.parallel().tween_property(right_hand,"rotation_degrees",0.0,idle_speed)
			tweenR.tween_property(right_hand,"position",Vector2(1536.0 - 32.0,768.0),idle_speed)
			
			tweenH.finished.connect(func():
				if track == "idle":
					track = attack_list.pick_random()
			, CONNECT_ONE_SHOT)
		
		"paw_slam":
			var left_hand_start_X = left_hand.position.x
			var right_hand_start_X = right_hand.position.x
			
			# 1. Move both hands up initially
			var initial_tween = create_tween().set_parallel(true)
			initial_tween.tween_property(left_hand, "position", Vector2(left_hand_start_X, 208.0), 0.5)
			initial_tween.tween_property(right_hand, "position", Vector2(right_hand_start_X, 208.0), 0.5)
			await initial_tween.finished

			for loops in range(0, randi_range(1, 2) * (3-hands_left)):
				if left_hand_alive:
					paw_slamming = 1
					await get_tree().create_timer(1.5 * hands_left).timeout
					paw_slamming = 3
					var slamL = create_tween()
					slamL.tween_property(left_hand, "position", Vector2(left_hand.position.x, 1088.0), 0.6)
					if not right_hand_alive:
						left_hand_start_X = left_hand.position.x
					slamL.tween_property(left_hand, "position", Vector2(left_hand_start_X, 208.0), 0.5)
					await slamL.finished
				
				if right_hand_alive:
					paw_slamming = 2
					await get_tree().create_timer(1.5 * hands_left).timeout
					paw_slamming = 3
					var slamR = create_tween()
					slamR.tween_property(right_hand, "position", Vector2(right_hand.position.x, 1088.0), 0.6)
					if not left_hand_alive:
						right_hand_start_X = right_hand.position.x
					slamR.tween_property(right_hand, "position", Vector2(right_hand_start_X, 208.0), 0.5)
					await slamR.finished

			paw_slamming = 0
			track = "idle"
			
		"side_sweep":
			var initial_tween = create_tween().set_parallel(true)
			var left_y = 0
			var right_y = 0
			match randi_range(1,2): #Attack Type; 1 = bottom; 2 = top;
				1:
					left_y = 1088.0
					right_y = 1088.0
				2:
					left_y = 896.0
					right_y = 896.0
			left_y = left_y if left_hand_alive else 0.0
			right_y = right_y if right_hand_alive else 0.0
			initial_tween.tween_property(left_hand,"position",Vector2(64.0,left_y),0.75)
			initial_tween.tween_property(left_hand,"rotation_degrees",-90.0,0.75)
			initial_tween.tween_property(right_hand,"position",Vector2(1984.0,right_y),0.75)
			initial_tween.tween_property(right_hand,"rotation_degrees",90.0,0.75)
			await initial_tween.finished
			await get_tree().create_timer(2.0).timeout
			var slam_tween = create_tween().set_parallel(true)
			slam_tween.tween_property(left_hand,"position",Vector2(960.0 if left_y == right_y else 1984.0,left_y),1.0)
			slam_tween.tween_property(right_hand,"position",Vector2(1088.0 if left_y == right_y else 64.0,right_y),1.0)
			await slam_tween.finished
			track = "idle"
		
		"floor_slam":
			var slam = create_tween()
			slam.set_loops(clamp(floor(GlobVar.stage/15.0)*2+1,3,INF))
			slam.tween_property(left_hand,"position:y",1088.0,0.2)
			slam.parallel().tween_property(right_hand,"position:y",1088.0,0.2)
			slam.tween_callback(summon_crab)
			slam.tween_property(left_hand,"position:y",768.0,0.2)
			slam.parallel().tween_property(right_hand,"position:y",768.0,0.2)
			await slam.finished
			track = "idle"
		"stunned":
			var flash = create_tween()
			var move_head = create_tween()
			flash.set_loops()
			flash.tween_property(head, "modulate", Color(10, 10, 10, 1), 0.0)
			flash.tween_interval(1.0 / 12.0)
			flash.tween_property(head, "modulate", Color(1, 1, 1, 1), 0.0)
			flash.tween_interval(1.0 / 12.0)
			move_head.tween_property(head,"position",Vector2(head.position.x,960.0),3.0).from(head.position)

func watch_target():
	var pupil_angle = $Head.global_position.angle_to_point(Vector2(GlobVar.PlayerX,GlobVar.PlayerY))
	$Head/Pupils.position = Vector2(37*cos(pupil_angle),13*sin(pupil_angle))

func _on_left_hurtbox_area_entered(area: Area2D) -> void:
	if area is Bullet:
		left_hand_health -= area.damage
		left_hand.modulate = Color(255,0,0,255)
		area.remove()
		if left_hand_health <= 0:
			left_hand_alive = false
			left_hand.queue_free()
		await get_tree().create_timer(0.1).timeout
		left_hand.modulate = Color(1,1,1,1)
		

func _on_right_hurtbox_area_entered(area: Area2D) -> void:
	if area is Bullet:
		right_hand_health -= area.damage
		right_hand.modulate = Color(255,0,0,255)
		area.remove()
		if right_hand_health <= 0:
			right_hand_alive = false
			right_hand.queue_free()
		await get_tree().create_timer(0.1).timeout
		right_hand.modulate = Color(1,1,1,1)

func _on_head_hurtbox_area_entered(area: Area2D) -> void:
	if area is Bite and track == "stunned":
		killed.emit(head.position)
		SignalBus.bite_death.emit(50)
		queue_free()

func boss_intro():
	await get_tree().create_timer(3.0).timeout
	visible = true
	$Head.play("intro")
	$Head/Body.play("intro")
	var raise_hands = create_tween().set_parallel(true)
	raise_hands.tween_property(left_hand,"position",Vector2(544.0,768.0),7.0/12.0).from(Vector2(544.0,1172.0))
	raise_hands.tween_property(right_hand,"position",Vector2(1504.0,768.0),7.0/12.0).from(Vector2(1504.0,1172.0))

func summon_crab():
	var crab = CRAB_SCENE.instantiate()
	crab.global_position = Vector2(randi_range(96,1952),96)
	crab.airborne = true
	crab.health /= 3.0
	get_tree().current_scene.add_child(crab)
