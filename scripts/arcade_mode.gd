extends Node
var arcade_mode = false :
	set(value):
		arcade_mode = value
		update_input_mapping()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("fn") and Input.is_action_pressed("crouch") and Input.is_action_pressed("lock_position"):
		arcade_mode = not arcade_mode

func update_input_mapping() -> void:
	if arcade_mode:
		InputMap.action_erase_events("jump")
		InputMap.action_erase_events("lock_position")
		InputMap.action_erase_events("bite")
		InputMap.action_erase_events("crouch")
		InputMap.action_erase_events("gadget")
		InputMap.action_add_event("jump", (func(): var e = InputEventJoypadButton.new(); e.button_index = JOY_BUTTON_Y; return e).call())
		InputMap.action_add_event("lock_position", (func(): var e = InputEventJoypadButton.new(); e.button_index = JOY_BUTTON_A; return e).call())
		InputMap.action_add_event("bite", (func(): var e = InputEventJoypadMotion.new(); e.axis = JOY_AXIS_TRIGGER_LEFT; e.axis_value = 1.0; return e).call())
		InputMap.action_add_event("crouch", (func(): var e = InputEventJoypadButton.new(); e.button_index = JOY_BUTTON_B; return e).call())
		InputMap.action_add_event("gadget", (func(): var e = InputEventJoypadMotion.new(); e.axis = JOY_AXIS_TRIGGER_RIGHT; e.axis_value = 1.0; return e).call())
	else:
		InputMap.load_from_project_settings()

func _process(delta: float) -> void:
	print(arcade_mode)
