extends Sprite2D
class_name EffectSprite2D

@export_range(0,16) var animation_frames: int = 0
@export_range(0, 60, 1, "suffix:fps") var animation_rate = 0
@export_range(0,16) var randomize_frames: int
@export_range(0, 60, 1, "suffix:fps") var randomize_rate = 0
@export_range(0, 60, 1, "suffix:fps") var strobe_rate = 0
@export var random_hflip = false
@export var random_vflip = false

func randomize_sprite(forbid_same_frame=false):
	if randomize_frames:
		var new_frame = -1
		while new_frame == -1 or (frame == new_frame and forbid_same_frame):
			new_frame = range(randomize_frames).pick_random()
		frame = new_frame
	if random_hflip:
		flip_h = randf() > 0.5
	if random_vflip:
		flip_v = randf() > 0.5

func advance_animation():
	if frame >= animation_frames - 1:
		frame = 0
	else:
		frame += 1

func strobe():
	visible = !visible

var cumers: Array[Cumer]
func _process(delta: float) -> void:
	for c in cumers:
		c.add(delta)

func reset() -> void:
	cumers.clear()
	if is_node_ready():
		_ready()

func _ready() -> void:
	randomize_sprite()
	if randomize_rate > 0:
		cumers.append(Cumer.new(randomize_rate, randomize_sprite.bind(true)))
	if animation_frames and animation_rate > 0:
		cumers.append(Cumer.new(animation_rate, advance_animation))
	if strobe_rate:
		cumers.append(Cumer.new(strobe_rate, strobe))
