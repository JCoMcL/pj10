extends Node2D
class_name Game

@export var new_entity_region: Node2D
@export var team_colors = {"Friendly": Color.WHITE, "Enemy" : Color("ff5277")}
@export var lives: Lives
@export var current_player: Player
@export var player_spawn_point: Marker2D

func get_team_color(o: CollisionObject2D) -> Color:
	for layer in Utils.seperate_layers(o.collision_layer):
		if layer in team_colors:
			return team_colors[layer]
	for layer in Utils.seperate_layers(~o.collision_mask):
		if layer in team_colors:
			return team_colors[layer]

	return Color.MAGENTA

func _on_player_died():
	if not lives:
		return _lose()

	await Utils.delay(2)
	var next_life = lives.get_life()
	if not next_life:
		return _lose()
	spawn_player(next_life)
	set_active_player(next_life)

func spawn_player(p: Player):
	new_entity_region.add_child(p)
	if player_spawn_point:
		p.global_position = player_spawn_point.global_position
	else:
		p.global_position = Vector2(30, 30)
	p.wakeup()

func set_active_player(p: Player):
	current_player = p
	if not p.expire.is_connected(_on_player_died):
		p.expire.connect(_on_player_died)

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

func _ready():
	if not current_player:
		spawn_player(lives.get_life())
