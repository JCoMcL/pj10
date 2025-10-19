extends Object
class_name InputTracker

var movement_input: Vector2

var _input_left: float
var _input_right: float
var _input_up: float
var _input_down: float

func _input(ev: InputEvent) -> void:
	if ev.is_action("left"):
		_input_left = ev.get_action_strength("left")
	if ev.is_action("right"):
		_input_right = ev.get_action_strength("right")
	if ev.is_action("up"):
		_input_up = ev.get_action_strength("up")
	if ev.is_action("down"):
		_input_down = ev.get_action_strength("down")

	movement_input = Vector2(_input_right - _input_left, _input_down - _input_up).normalized()
