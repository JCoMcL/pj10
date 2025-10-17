extends Bullet

func _process(delta):
	if abs(velocity.y) > 200:
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 0
