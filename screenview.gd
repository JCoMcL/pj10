extends TextureRect

func _input(event: InputEvent) -> void:
	$SubViewport.push_input(event)
