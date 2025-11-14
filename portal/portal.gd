extends AnimatedSprite2D

func show_children():
	$Sheen.visible = true
	$Swirl.visible = true
func hide_children():
	$Sheen.visible = false
	$Swirl.visible = false

func closing_anim():
	hide_children()
	play("closing")
	SFXPlayer.get_sfx_player(self).play_sfx("shkum")
	await animation_finished
	visible = false

func idle_anim():
	play("default")
	show_children()

func opening_anim():
	visible = true
	hide_children()
	play("opening")
	var sfx = SFXPlayer.get_sfx_player(self)
	sfx.play_sfx("kshrum")
	animation_finished.connect(idle_anim, CONNECT_ONE_SHOT)

func _ready():
	visible=false
	opening_anim.call_deferred()

