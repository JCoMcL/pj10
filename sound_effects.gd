extends AudioStreamPlayer2D
class_name SFXPlayer

var sfx = {}

func _build_sfx_table():
	var sfx_dir = "res://audio/sfx"
	var d = DirAccess.open(sfx_dir)
	for f in d.get_files():
		if f.ends_with(".wav"):
			var res = ResourceLoader.load("%s/%s" % [sfx_dir, f])
			if res:
				var key = f.get_basename()
				assert(key)
				assert(not sfx.has(key))
				sfx[key] = res

func play_sfx(effect_name: String) -> bool:
	if not sfx:
		_build_sfx_table()
	if not sfx.has(effect_name):
		return false
	play()
	get_stream_playback().play_stream(sfx[effect_name])
	return true

func _ready():
	if not sfx:
		_build_sfx_table()
	var game = Game.get_game(self)
	if game and not game.sfx_player:
		game.sfx_player = self
