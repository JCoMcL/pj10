extends SubViewport

@export var resolution_scale = 1.0
@export var game_scene: PackedScene
@export var default_on = true
var layer_scene = preload("res://crt_layer.tscn")
@onready var crt: CanvasLayer = $CRTLayer
var game: Node

func restart_game():
	await Utils.delay(3)
	Fuckit.game_over.emit()
	game.queue_free()
	await Utils.delay(2)
	on_power_on()

func on_power_on():
	if not game_scene:
		return
	if game:
		game.free()
	game = game_scene.instantiate()
	crt.add_child(game)
	if game is Game:
		if game.play_area:
			size = Vector2i(game.play_area.width, game.play_area.height)
		if not game.lose.is_connected(restart_game):
			game.lose.connect(restart_game)
	crt.resolution = size * resolution_scale

func _ready():
	Fuckit.power_on.connect(on_power_on)
	if default_on:
		on_power_on()
