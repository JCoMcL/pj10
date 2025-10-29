extends Node2D
class_name Game

@export var play_area: PlayArea
@export var new_entity_region: Node2D
@export var lives: Lives
@export var current_player: Player
@export var player_spawn_point: Marker2D
@export var sfx_player: SFXPlayer
@export var dialgoue_screens: Array[DialogueScreen]
@export var waves: Array[PackedScene]
@export var wave: int = 0

func _on_player_died():
	if not lives:
		return _lose()

	await Utils.delay(1)
	var next_life = lives.get_life()
	if not next_life:
		return _lose()
	spawn_player(next_life)
	set_active_player(next_life)

func spawn_player(p: Player):
	if player_spawn_point:
		player_spawn_point.add_child(p)
		p.reparent(new_entity_region)
	else:
		new_entity_region.add_child(p)
	p.wakeup() # TODO maybe this should always be triggered manually?

func set_active_player(p: Player):
	current_player = p
	if not p.expire.is_connected(_on_player_died):
		p.expire.connect(_on_player_died)

func on_beat_wave():
	_win()

func spawn_wave(w: PackedScene):
	var n = w.instantiate()
	await add_to_playfield(n, self)
	n.expire.connect(on_beat_wave)
	n.start()

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

static func add_to_playfield(o: Node2D, from: Node2D):
	var parent: Node2D
	var game = get_game(from)
	if not game.is_node_ready():
		await game.ready
	if game and game.new_entity_region:
		parent = game.new_entity_region
	else:
		parent = from.get_parent()
	if not o.get_parent():
		from.add_child(o)
	o.reparent(parent)
	o.global_position = from.global_position

func on_dialogue_finished():
	dialgoue_screens[0].visible = false
	if new_entity_region:
		new_entity_region.process_mode = Node.PROCESS_MODE_INHERIT
	_ready()

func open_dialogue():
	if new_entity_region:
		new_entity_region.process_mode = Node.PROCESS_MODE_DISABLED
	dialgoue_screens[0].activate()
	dialgoue_screens[0].dialogue_finished.connect(on_dialogue_finished, CONNECT_ONE_SHOT)

func _ready():
	for d in dialgoue_screens:
		d.visible = false
	if not current_player and lives and lives.has_life():
		await spawn_wave(waves[wave])
		spawn_player(lives.get_life())
	else:
		open_dialogue()
