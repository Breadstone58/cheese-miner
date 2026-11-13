extends CanvasLayer
# bro.
var last_money_tier: = 0
var moneylines = {
	0: "Bring the brie.",
	1: "It's the Ched' life.",
	2: "Very gouda.",
	3: "Cheese pun.",
	4: "Gotta fetch the feta.",
	5: "Orange you gl.. wait.. no...",
	6: "DON'T LEAVE ME PROVALONE.",
	7: "Hungry for havarti.",
	8: "I'm the goat...cheese.",
	9: "Do I even like cheese?",
	10: "Cheddar is always better."
}

@onready var pause: Control = $PauseMenu
var pause_select = [36, 228, 420]
var current_selection: int = 0

var game_paused: bool = false:
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		$PauseMenu.visible = game_paused

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	SignalBus.level_goal.connect(_on_goal_change)
	$Control/MoneyImage.frame = GlobVar.money_disp_frame
	$Control/EnergyImage.frame = GlobVar.energy_disp_frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fn"):
		if not game_paused:
			open_pause_menu()
		else:
			handle_pause_selection()

	if game_paused:
		handle_pause_navigation()
		return

	# --- Normal Gameplay HUD Updates ---
	$Control/Stage.text = str(GlobVar.stage)
	var uhhitsthehpson = max(0, 296.0 * (float(GlobVar.playerHealth) / GlobVar.healthMax))
	$"Control/Hp Bar Back/Hp Bar Color".size.x = uhhitsthehpson
	$"Control/Hp Bar Back/Hp Bar Color/HpShading".size.x = uhhitsthehpson
	$"Control/Hp Bar Back/Hp Bar Color/HpShading2".size.x = uhhitsthehpson
	$"Control/Hp Bar Back/Hp Bar Color/HpDisp".text = str(int(GlobVar.playerHealth)) + "/" + str(GlobVar.healthMax)
	$"Control/Hp Bar Back".visible = true
	
	# money time...
	var money_max: = 100.0
	var moneynotyetson: = fmod(float(GlobVar.money), money_max)
	var moneyson: = 176 * (moneynotyetson / money_max)
	var current_tier: = int(floor(float(GlobVar.money) / money_max))
	$"Control/Hp Bar Back/Cash Bar Back/Cash Bar Color".size.x = moneyson
	$"Control/Hp Bar Back/Cash Bar Back/Cash Bar Color/CashShading".size.x = moneyson
	$"Control/Hp Bar Back/Cash Bar Back/Cash Bar Color/CashShading2".size.x = moneyson
	$Control/MoneyLabel.text = "$" + str(GlobVar.money)
	$Control/MoneyImage.animation = "money" + str(GlobVar.positional_biome % 5)
	$Control/MoneyImage.play()
	$Control/MoneyImage.visible = true
	GlobVar.money_disp_frame = $Control/MoneyImage.frame
	
	if current_tier > GlobVar.last_money_tier:
		GlobVar.last_money_tier = current_tier
		var random_key: = int(randi() % moneylines.size())
		$cheddytext.text = moneylines[random_key]
		GlobVar.playerHealth = clamp(GlobVar.playerHealth + 25, 0, GlobVar.healthMax)
		$cheddytext/AnimationPlayer.play("text")
		
	for key in ItemID.gadget:
		if ItemID.gadget[key] == GlobVar.gadget:
			var energy_max = float(ItemID.energy[GlobVar.gadget])
			var uhhitstheenergyson = max(0, 176 * (float(GlobVar.energy) / energy_max) if energy_max > 0 else 0.0)
			$Control/GadgetImage.frame = key
			$Control/EnergyImage.visible = true
			$Control/EnergyAmount.visible = true
			$Control/GadgetImage.visible = true
			$"Control/Hp Bar Back/Cash Bar Back/Energy Bar Back".visible = true
			$"Control/Hp Bar Back/Cash Bar Back/Energy Bar Back/Energy Bar Color".size.x = uhhitstheenergyson
			$"Control/Hp Bar Back/Cash Bar Back/Energy Bar Back/Energy Bar Color/EnergyShading".size.x = uhhitstheenergyson
			$"Control/Hp Bar Back/Cash Bar Back/Energy Bar Back/Energy Bar Color/EnergyShading2".size.x = uhhitstheenergyson
			$Control/EnergyAmount.text = str(GlobVar.energy) + "/" + str(ItemID.energy[GlobVar.gadget])
			$Control/EnergyImage.play()
			GlobVar.energy_disp_frame = $Control/EnergyImage.frame
			
	if ArcadeMode.arcade_mode == true:
		$Control/GadgetImage/Tooltip.frame = 1


func _on_goal_change(goal: String) -> void:
	$Control/LevelGoal.text = goal


func open_pause_menu() -> void:
	game_paused = true
	current_selection = 0
	update_menu_position()


func handle_pause_navigation() -> void:
	if Input.is_action_just_pressed("aim_down"):
		current_selection = (current_selection + 1) % pause_select.size()
		update_menu_position()
		
	if Input.is_action_just_pressed("aim_up"):
		current_selection = (current_selection - 1 + pause_select.size()) % pause_select.size()
		update_menu_position()


func update_menu_position() -> void:
	$PauseMenu/ColorRect2/ReferenceRect.position.y = pause_select[current_selection]


func handle_pause_selection() -> void:
	if current_selection == 0:
		game_paused = false
	elif current_selection == 1:
		game_paused = false
		GlobVar.reset_to_default()
		SceneTransitions.transition_to("res://scenes/rooms/title.tscn", 1.0)
	else:
		get_tree().quit()
