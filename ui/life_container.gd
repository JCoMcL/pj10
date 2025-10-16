@tool
extends TextureRect
class_name LifeContainer

@export_range(1,3,1) var scaling = 1:
	set(val):
		scaling=val
		refresh()
var life: Unit:
	set(val):
		life = val
		refresh()
@export var life_scene: PackedScene:
	set(val):
		if val:
			life = val.instantiate()
		life_scene = val

func refresh():
	setup_life.call_deferred()

func setup_life():
	if not life:
		return
	var sprite = Unit.get_sprite(life)
	texture = sprite.texture
	size = texture.get_size() * scaling

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	life = life_scene.instantiate()
	setup_life()
