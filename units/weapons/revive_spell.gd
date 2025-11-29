extends Bullet

@export var duration = 1.5

func _hit(damage: int = 1) -> int:
	return 0

var animation_stage = 0
var countdown: float
func wakeup():
	super()
	countdown = duration
	animation_stage = 0

func revive(player: Player):
	var game = Game.get_game(self)
	Vfx.play("rise", player, Vector2.DOWN * 8)
	if game:
		game.lives.reclaim_life(player)
	else:
		player.wakeup()

func set_effect_size(f: float):
	var discretize = 24
	var discrete_effect_size = round(f * discretize) / discretize
	get_sprite().material.set_shader_parameter("scale", Vector2.ONE * discrete_effect_size)

var effect_size: float = 1.0
func _process(delta: float) -> void:
	countdown -= delta
	var countup = duration - countdown
	match animation_stage:
		0:
			effect_size = move_toward(0.0, 1.0, min(1.0, countup * 5))
			effect_size += sin(countdown * 5 * duration) * 0.05
			set_effect_size(effect_size)

			if countdown < 0.35:
				animation_stage += 1
				play_sfx("gasp")
				get_sprite().play_animation(3,7,8).connect(_expire, CONNECT_ONE_SHOT)
		1:
			effect_size = move_toward(effect_size, 1.0, 0.01 * delta)
			set_effect_size(effect_size)
			if countdown <= 0:
				animation_stage += 1
		2:
			play_sfx("boom")
			for result in Utils.get_objects_under_body(self, "Friendly", Utils.BODIES, get_world_2d()):
				if result is Player and not result.alive:
					revive(result)
			animation_stage += 1
		3:
			pass
