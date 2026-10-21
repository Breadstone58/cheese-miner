extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.level_goal.connect(_on_goal_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Control/Stage.text = str(GlobVar.stage)

func _on_goal_change(goal: String):
	$Control/LevelGoal.text = goal
