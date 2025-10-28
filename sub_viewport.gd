extends SubViewport

@export var scene: PackedScene

func restart_game():
	await Utils.delay(3)
	Fuckit.game_over.emit()
	get_child(0).queue_free()
	await Utils.delay(2)
	on_power_on()

func on_power_on():
	add_child(scene.instantiate())
	get_child(0).get_child(0).get_child(0).lose.connect(restart_game)

func _ready():
	Fuckit.power_on.connect(on_power_on)
