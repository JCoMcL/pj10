extends Shoota

var sustained_bullet: Unit
func shoot(towards:Variant = default_direction, parent:Node=null, mask:int=-1) -> Unit:
	if sustained_bullet and sustained_bullet.alive:
		sustained_bullet.direction = resolve_direction(towards)
		return sustained_bullet
	sustained_bullet = await super(towards, self, mask)
	if not sustained_bullet:
		return null
	autoshoot_disabled.connect(sustained_bullet._expire, Node.CONNECT_ONE_SHOT)
	return sustained_bullet

func _ready():
	super()
	oneshot=false
