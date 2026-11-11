extends CanvasLayer
# bro.
var last_money_tier: int = 0
var moneylines = {
	0: "Bring the\nbrie.",
	1: "It's the\nChed' life.",
	2: "Very\ngouda.",
	3: "Cheese\npun.",
	4: "Gotta fetch the feta.",
	5: "Orange you\ngl.. wait.. no...",
	6: "DON'T\nLEAVE ME\nPROVALONE.",
	7: "Hungry for havarti.",
	8: "I'm the goat...\n...\ncheese.",
	9: "Do I even like cheese?",
	10: "Cheddar is always better."
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.level_goal.connect(_on_goal_change)
	$Control/MoneyImage.frame = GlobVar.money_disp_frame
	$Control/EnergyImage.frame = GlobVar.energy_disp_frame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Control/Stage.text = str(GlobVar.stage)
	var uhhitsthehpson = max(0,296.0 * (float(GlobVar.playerHealth)/GlobVar.healthMax)) # me am coder.. me am set var... wtf am I doing with my lif
	$"Control/Hp Bar Back/Hp Bar Color".size.x = uhhitsthehpson
	$"Control/Hp Bar Back/Hp Bar Color/HpShading".size.x = uhhitsthehpson
	$"Control/Hp Bar Back/Hp Bar Color/HpShading2".size.x = uhhitsthehpson
	# $"Control/Hp Bar Back/Hp Bar Border".size.x = $"Control/Hp Bar Back/Hp Bar Color".size.x + 2
	$"Control/Hp Bar Back/Hp Bar Color/HpDisp".text = str(int(GlobVar.playerHealth)) + "/" + str(GlobVar.healthMax)
	$"Control/Hp Bar Back".visible = true
	# money time...
	var money_max: float = 100.0
	var moneynotyetson: float = fmod(float(GlobVar.money), money_max)
	var moneyson: float = 176* (moneynotyetson / money_max)
	var current_tier: int = int(floor(float(GlobVar.money) / money_max))
	$"Control/Hp Bar Back/Cash Bar Back/Cash Bar Color".size.x = moneyson
	$"Control/Hp Bar Back/Cash Bar Back/Cash Bar Color"/CashShading.size.x = moneyson
	$"Control/Hp Bar Back/Cash Bar Back/Cash Bar Color"/CashShading2.size.x = moneyson
	$Control/MoneyLabel.text = "$" + str(GlobVar.money)
	$Control/MoneyImage.animation = "money" + str(GlobVar.positional_biome % 5)
	$Control/MoneyImage.play()
	$Control/MoneyImage.visible = true
	GlobVar.money_disp_frame = $Control/MoneyImage.frame
	if current_tier > last_money_tier:
		last_money_tier = current_tier
		var random_key: int = randi() % moneylines.size()
		$cheddytext.text = moneylines[random_key]
		GlobVar.playerHealth = clamp(GlobVar.playerHealth + 25, 0, GlobVar.healthMax)
		$cheddytext/AnimationPlayer.play("text")
	for key in ItemID.gadget:
			if ItemID.gadget[key] == GlobVar.gadget:
				var energy_max = float(ItemID.energy[GlobVar.gadget])
				var uhhitstheenergyson = max(0,176 * (float(GlobVar.energy)/energy_max) if energy_max > 0 else 0.0)
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

func _on_goal_change(goal: String):
	$Control/LevelGoal.text = goal
