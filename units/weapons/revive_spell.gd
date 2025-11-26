extends Bullet

@export var duration = 1.5

func _hit(damage: int = 1) -> int:
	return 0

var countdown: float
func wakeup():
	super()
	countdown = duration

func _process(delta: float) -> void:
	countdown -= delta
	
	var countup = duration - countdown
	var effect_size: float
	effect_size = move_toward(0.0, 1.0, min(1.0, countup * 5))
	effect_size += sin(countdown * 5 * duration) * 0.05
	
	var discretize = 24
	effect_size *= discretize
	effect_size = round(effect_size)
	effect_size /= discretize
	
	get_sprite().material.set_shader_parameter("scale", Vector2.ONE * effect_size)

	if countdown <= 0:
		for result in Utils.get_objects_under_body(self, "Friendly", Utils.BODIES, get_world_2d()):
			print("result: %s" % result)
			if result is Player and not result.alive:
				print(result)
				var game = Game.get_game(self)
				if game:
					game.lives.reclaim_life(result)
				else:
					result.wakeup()
		super._hit()
