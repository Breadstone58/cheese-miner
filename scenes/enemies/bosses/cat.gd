extends Node2D

@onready var head: AnimatedSprite2D = $Head
@onready var left_hand: AnimatedSprite2D = $"Left Hand"
@onready var right_hand: AnimatedSprite2D = $"Right Hand"

var track = "idle" :
	set(value):
		track = value
		play_animation()

var hands_left = 2
var left_hand_alive = true
var right_hand_alive = true

var attack_list = ["paw_slam","side_sweep"]
var paw_slamming = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_animation()
	$"Left Hand/Hitbox".damage = GlobVar.stage
	$"Right Hand/Hitbox".damage = GlobVar.stage


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			slam_tween.tween_property(left_hand,"position",Vector2(960.0 if left_y == right_y else 1984.0,left_y),1.0 if left_y == right_y else 2.0)
			slam_tween.tween_property(right_hand,"position",Vector2(1088.0 if left_y == right_y else 64.0,right_y),1.0 if left_y == right_y else 2.0)
			await slam_tween.finished
			track = "idle"
			
func watch_target():
	pass
