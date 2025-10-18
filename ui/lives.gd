@tool
extends Container
class_name Lives

@export_tool_button("refresh") var f = refresh
@export_range(1,3,1) var scaling = 2:
	set(i):
		scaling = i
		for c in get_children():
			c.scaling = i
		refresh.call_deferred()

func refresh():
	size = Vector2.ZERO
	for c in get_children():
		if c is LifeContainer:
			c.setup_life()
		size.x += c.size.x
		size.y = max(size.y, c.size.y)
	position.x = get_parent().size.x - size.x
	position.y = 0

func get_life() -> Unit:
	for c in get_children():
		if c is LifeContainer:
			var l = c.life
			if l and l.alive:
				return l
	return null

func _ready():
	var game = Game.get_game(self)
	if game and not game.lives:
		game.lives = self
