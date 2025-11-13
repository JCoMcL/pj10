extends Shoota

@export var sustain_sfx:StringName:
	set(s):
		sustain_sfx = s
		set_sfx_cumer()
@export_range(0.1, 20) var sustain_sfx_rate = 5.0:
	set(f):
		sustain_sfx_rate = f
		set_sfx_cumer()

var sfx_cumer: Cumer
var sustained_bullet: Unit
func shoot(towards:Variant = default_direction, parent:Node=null, mask:int=-1) -> Unit:
	if sustained_bullet and sustained_bullet.alive:
		sustained_bullet.direction = resolve_direction(towards)
		return sustained_bullet
	sustained_bullet = await super(towards, self, mask)
	if not sustained_bullet:
		return null
	SFXPlayer.get_sfx_player(self).play_sfx(sustain_sfx)
	return sustained_bullet

func set_sfx_cumer():
	if sustain_sfx and sustain_sfx_rate > 0:
		sfx_cumer=Cumer.new(sustain_sfx_rate, SFXPlayer.get_sfx_player(self).play_sfx.bind(sustain_sfx))

func _ready():
	super()
	oneshot=false

func _process(delta):
	super(delta)
	if sustained_bullet and sustained_bullet.alive:
		if not autoshoot:
			sustained_bullet._expire()
			sfx_cumer.reset()
		else:
			sfx_cumer.add(delta)
