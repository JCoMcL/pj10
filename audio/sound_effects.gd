extends AudioStreamPlayer2D
class_name SFXPlayer

var sfx = {}

func _build_sfx_table():
	var sfx_dir = "res://audio/sfx"
	for f in ResourceLoader.list_directory(sfx_dir):
		if f.ends_with(".wav"):
			var res = ResourceLoader.load("%s/%s" % [sfx_dir, f])
			if res:
				var key = f.get_basename()
				assert(key)
				assert(not sfx.has(key))
				sfx[key] = res


var plays_back = {}
func get_playback(audio_player: Node) -> AudioStreamPlayback:
	if plays_back.has(audio_player):
		return plays_back[audio_player]
	audio_player.play()
	plays_back[audio_player] = audio_player.get_stream_playback()
	return get_playback(audio_player)

var playback:AudioStreamPlaybackPolyphonic
var relay_playback: AudioStreamPlaybackPolyphonic
func play_sfx(effect_name: String) -> bool:
	if not sfx:
		_build_sfx_table()
	if not sfx.has(effect_name):
		return false

	get_playback(self).play_stream(sfx[effect_name])
	if Fuckit.audio_relays.has(self):
		var relay = Fuckit.audio_relays[self]
		if is_instance_valid(relay):
			get_playback(relay).play_stream(sfx[effect_name])
	return true

static func get_sfx_player(from: Node) -> SFXPlayer:
	if "_sfx_player" in from and from._sfx_player is SFXPlayer:
		return from._sfx_player
	var game = Game.get_game(from)
	if game and game.sfx_player:
		return game.sfx_player
	return GlobalSFXPlayer

func _ready():
	if not sfx:
		_build_sfx_table()
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 5
	var game = Game.get_game(self)
	if game and not game.sfx_player:
		game.sfx_player = self
	Fuckit.relay_audio(self)
