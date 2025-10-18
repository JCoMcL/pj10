extends Shoota
class_name OrbThrower

enum {ORBITING, WIND_UP, LAUNCHING, PASSIVE}
var bullet_state: Dictionary

func _on_bullet_expire(b: Unit):
	b.velocity = Vector2.ZERO
	var new_bullet = await spawn_bullet() #this is probably the same bullet
	assert(bullet_state.size() == ammo_count)

func shoot(direction:Vector2, parent:Node=null, mask:int=-1) -> Unit:
	for b in bullet_state.keys():
		if bullet_state[b] == ORBITING:
			bullet_state[b] = WIND_UP
			return b
	return null

func _physics_process(delta: float) -> void:
	for b in bullet_state.keys():
		match bullet_state[b]:
			ORBITING:
				b.velocity += (global_position - b.global_position) * delta * 40
				b.velocity *= 0.8
			WIND_UP:
				if b.velocity.y < 140:
					b.velocity.y += 900 * delta
				else:
					bullet_state[b] = LAUNCHING
			LAUNCHING:
				if b.velocity.y > -600:
					b.velocity.y -= 1600 * delta
				else:
					bullet_state[b] = PASSIVE

func spawn_bullet():
	var b = await super.shoot(Vector2.ZERO)
	b.expire.connect(_on_bullet_expire.bind(b), CONNECT_ONE_SHOT)
	bullet_state[b] = ORBITING

func _ready() -> void:
	for i in range(ammo_count):
		spawn_bullet()
