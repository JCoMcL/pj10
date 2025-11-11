extends EffectSprite2D
class_name VFXSprite

signal expire
func _expire():
	expire.emit()

func play(start_frame:int, end_frame:int, rate:float):
	for i in range(end_frame - start_frame + 1):
		frame = start_frame + i
		await Utils.delay(1.0/rate)
	_expire()
	
