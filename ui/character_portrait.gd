extends Control
class_name CharacterPortrait

var selectable = true

func deselect_character(lc: LifeContainer):
	lc.life = null
	$LifeContainer.self_modulate = Color.WHITE
	selectable = true

func select_character():
	var screen = DialogueScreen.get_dialogue_screen(self)
	if screen and $LifeContainer.life:
		var life_container = screen.submit($LifeContainer.life)
		if life_container:
			screen.push_back_handler(deselect_character.bind(life_container))
			$LifeContainer.self_modulate = Color("17121d")
			selectable = false

func _gui_input(event: InputEvent) -> void:
	if selectable and event.is_action_pressed("fire"):
		select_character()
		accept_event()
	
