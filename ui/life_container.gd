@tool
extends Control
class_name LifeContainer

@export_range(1,3,1) var scaling = 2:
	set(val):
		scaling=val
		setup_life.call_deferred()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not get_life() or get_life() is not Unit:
		warnings.append("must contain a Unit")
	return warnings

func get_life() -> Unit: #if only it were so easy
	if get_child_count():
		return get_child(0)
	else:
		assert(false)
		return null

func setup_life():
	var life = get_life()
	if not life:
		return
	print("before: %s" % size)
	size = Unit.get_sprite(life).texture.get_size() * scaling
	print("after: %s" % size)
	life.scale = Vector2.ONE * scaling
	life.position = size/2
	life.process_mode = Node.PROCESS_MODE_DISABLED

func attach_life(life: Unit):
	if not get_life() :
		add_child(life)

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	setup_life()
