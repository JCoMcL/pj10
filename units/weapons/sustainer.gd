extends Shoota

var sustained_bullet: Unit
func shoot(towards:Variant = default_direction, parent:Node=null, mask:int=-1) -> Unit:
	if sustained_bullet and sustained_bullet.alive:
		sustained_bullet.direction = resolve_direction(towards)
		return sustained_bullet
	sustained_bullet = await super(towards, self, mask)
	if not sustained_bullet:
		return null
	return sustained_bullet

func _ready():
	super()
	oneshot=false

func _process(delta):
	super(delta)
	if sustained_bullet and sustained_bullet.alive and not autoshoot:
		sustained_bullet._expire()
