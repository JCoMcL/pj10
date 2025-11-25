extends Bullet

func _hit(damage: int = 1) -> int:
	return 0

var countdown: float
func wakeup():
	super()
	countdown = 1.0

func _process(delta: float) -> void:
	countdown -= delta
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
		_expire()
