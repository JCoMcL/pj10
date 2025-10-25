extends Object
class_name Cumer

var f: Callable
var t: float
var accum: float

func _init(rate: float, callback: Callable):
	assert(rate > 0)
	t = 1.0/rate
	f = callback

func add(delta: float):
	accum += delta
	while accum > t:
		accum -= t
		f.call()
