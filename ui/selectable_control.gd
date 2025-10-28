extends Control
class_name SelectableControl

@export var selectable = true

var direction_table = {
	"up" : (func(c): return c.focus_neighbor_top).bind(self),
	"down" : (func(c): return c.focus_neighbor_bottom).bind(self),
	"left" : (func(c): return c.focus_neighbor_left).bind(self),
	"right" : (func(c): return c.focus_neighbor_right).bind(self)
}

func transfer_focus(s: String) -> bool:
	if not s in direction_table:
		return false
	var n_path = direction_table[s].call()
	if not n_path:
		return false
	var n = get_node(n_path)
	if not n or n is not Control:
		return false
	if n is SelectableControl and not n.selectable:
		if n.transfer_focus(s):
			return true
		return false
	n.grab_focus()
	return true

func _select() -> bool:
	if not selectable:
		return false
	accept_event()
	play_sfx("blooph")
	play_sfx("blup")
	if button_interface:
		button_interface.button_pressed = true
		button_interface.pressed.emit()
	return true

func play_sfx(s):
	return SFXPlayer.get_sfx_player(self).play_sfx(s)

func _gui_input(ev: InputEvent) -> void:
	for d in direction_table.keys():
		if ev.is_action_pressed(d):
			if transfer_focus(d):
				play_sfx("blup")
			accept_event()
			break
	if ev.is_action_pressed("fire"):
		_select()
	if ev.is_action_released("fire"):
		if button_interface:
			button_interface.button_pressed = false

var button_interface: BaseButton
func _ready():
	var c = self as Control
	if c is BaseButton:
		button_interface = c as BaseButton
	if selectable:
		focus_mode = 2
