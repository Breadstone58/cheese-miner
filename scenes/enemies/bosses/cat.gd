extends Node2D

@onready var head: AnimatedSprite2D = $Head
@onready var left_hand: AnimatedSprite2D = $"Left Hand"
@onready var right_hand: AnimatedSprite2D = $"Right Hand"

var track = "idle" :
	set(value):
		track = value
		play_animation()
		
var attack_list = ["paw_slam"]
var paw_slamming = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_animation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	watch_target()
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
			var tweenH = get_tree().create_tween()
			var tweenL = get_tree().create_tween()
			var tweenR = get_tree().create_tween()
			var idles = randi_range(1,3)
			tweenH.set_loops(idles)
			tweenH.tween_property(head,"position",Vector2(1024.0,576.0 + 32.0),0.75)
			tweenH.tween_property(head,"position",Vector2(1024.0,576.0 - 32.0),0.75)
			tweenL.set_loops(idles)
			tweenL.tween_property(left_hand,"position",Vector2(512.0 - 32.0,768.0),0.75)
			tweenL.tween_property(left_hand,"position",Vector2(512.0 + 32.0,768.0),0.75)
			tweenR.set_loops(idles)
			tweenR.tween_property(right_hand,"position",Vector2(1536.0 + 32.0,768.0),0.75)
			tweenR.tween_property(right_hand,"position",Vector2(1536.0 - 32.0,768.0),0.75)
			
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

			for loops in range(0, randi_range(1, 2)):
				paw_slamming = 1
				await get_tree().create_timer(3.0).timeout
				paw_slamming = 3
				var slamL = create_tween()
				slamL.tween_property(left_hand, "position", Vector2(left_hand.position.x, 1088.0), 0.6)
				slamL.tween_property(left_hand, "position", Vector2(left_hand_start_X, 208.0), 0.5)
				await slamL.finished
				
				paw_slamming = 2
				await get_tree().create_timer(3.0).timeout
				paw_slamming = 3
				var slamR = create_tween()
				slamR.tween_property(right_hand, "position", Vector2(right_hand.position.x, 1088.0), 0.6)
				slamR.tween_property(right_hand, "position", Vector2(right_hand_start_X, 208.0), 0.5)
				await slamR.finished

			paw_slamming = 0
			track = "idle"
			
func watch_target():
	pass
