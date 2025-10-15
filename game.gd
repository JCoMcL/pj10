extends Node2D
class_name Game

@export var new_entity_region: Node2D
@export var team_colors = {"Friendly": Color.WHITE, "Enemy" : Color("ff5277")}

func get_team_color(o: CollisionObject2D) -> Color:
	for layer in Utils.seperate_layers(o.collision_layer):
		if layer in team_colors:
			return team_colors[layer]
	for layer in Utils.seperate_layers(~o.collision_mask):
		if layer in team_colors:
			return team_colors[layer]

	return Color.MAGENTA

signal lose
func _lose():
	lose.emit()

signal win
func _win():
	win.emit()

var score = 0
signal score_changed(score: int)

func add_score(points: int):
	score += points
	score_changed.emit(score)

static func get_game(from: Node) -> Game:
	while from and from is not Game:
		from = from.get_parent()
	return from
