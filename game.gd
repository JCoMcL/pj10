extends Node2D
class_name Game

@export var new_entity_region: Node2D

signal lose
func _lose():
	lose.emit()
	
signal win
func _win():
	win.emit()

signal score_changed(score: int)
var score = 0:
	set(i):
		score = i
		score_changed.emit(score)

static func get_game(from: Node) -> Game:
	while from and from is not Game:
		from = from.get_parent()
	return from
