extends Control
class_name DialogueScreen

@export var confirm_button: Button
@export var initial_focus: Control
@export var lives: Lives

func submit(something):
	if something is Unit and lives:
		lives.add_life(something)
		if lives.is_filled():
			confirm_button.disabled=false
			confirm_button.grab_focus()
	else:
		print("unhandled submit: %s" % something)

signal dialogue_finished
func confirm():
	var game = Game.get_game(self)
	if game:
		if game.lives:
			lives.commune(game.lives)
		dialogue_finished.emit()

func activate():
	visible = true
	if initial_focus:
		initial_focus.grab_focus.call_deferred()

func _ready():
	activate()
	if confirm_button:
		confirm_button.disabled = true
		confirm_button.pressed.connect(confirm)

static func get_dialogue_screen(from: Node):
	while from and from is not DialogueScreen:
		from = from.get_parent()
	return from
