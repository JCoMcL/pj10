extends Control
class_name CharacterPortrait

func select_character():
	var screen = DialogueScreen.get_dialogue_screen(self)
	if screen and $LifeContainer.life:
		screen.submit($LifeContainer.life)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire") or event.is_action_pressed("ui_accept"):
		select_character()
		accept_event()
	
