extends Marker2D

func _ready():
	var game: Game = Game.get_game(self)
	if not game.player_spawn_point:
		game.player_spawn_point = self
