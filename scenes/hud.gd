extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.level_goal.connect(_on_goal_change)
	$Control/MoneyImage.frame = GlobVar.money_disp_frame
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Control/Stage.text = str(GlobVar.stage)
	$"Control/Hp Bar Back/Hp Bar Color".size.x = max(0,300.0 * (float(GlobVar.playerHealth)/GlobVar.healthMax))
	$"Control/Hp Bar Back/Hp Bar Border".size.x = $"Control/Hp Bar Back/Hp Bar Color".size.x + 2
	$"Control/Hp Bar Back/Hp Bar Color/HpDisp".text = str(int(GlobVar.playerHealth)) + "/" + str(GlobVar.healthMax)
	$"Control/Hp Bar Back".visible = true
	$Control/MoneyLabel.text = "$" + str(GlobVar.money)
	GlobVar.money_disp_frame = $Control/MoneyImage.frame

func _on_goal_change(goal: String):
	$Control/LevelGoal.text = goal
