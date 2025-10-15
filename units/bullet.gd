extends Unit

func _ready() -> void:
	super()
	$Sprite2D.modulate = Game.get_game(self).get_team_color(self)
