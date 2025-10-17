class_name Unit
extends CharacterBody2D

@export var behaviours: Array[Behaviour]
@export var health: int = 0
@export var auto_free = true
@export var points_worth = 0
@export var expire_outside_play_area = false

signal expire
@onready var current_health = health
var direction: Vector2
var monitoring_play_area = false:
	set(b):
		monitoring_play_area = b
		if b:
			collision_layer |= Utils.layers["AreaBounded"]
		else:
			collision_layer &= ~Utils.layers["AreaBounded"]
var inside_play_area: bool

func _on_enter_play_area():
	inside_play_area = true

func _on_exit_play_area():
	inside_play_area = false
	assert(monitoring_play_area)
	if alive and expire_outside_play_area:
		_expire()

static func get_sprite(instance: Unit) -> Sprite2D:
	for c in instance.get_children():
		if c is Sprite2D:
			return c
	return null

@onready var _sfx_player: SFXPlayer
func _set_sfx_player():
	for c in get_children():
		if c is SFXPlayer:
			_sfx_player = c

func play_sfx(effect_name: String):
	if _sfx_player and _sfx_player.play_sfx(effect_name):
		return
	var game = Game.get_game(self)
	if game and game.sfx_player and game.sfx_player.play_sfx(effect_name):
		return
	assert(GlobalSFXPlayer.play_sfx(effect_name))

var alive: bool = true
func _expire():
	if not alive:
		print("Warning: %s: double expire" % self)
		return
	alive = false
	if points_worth:
		Game.get_game(self).add_score(points_worth)
	if auto_free:
		queue_free()
	expire.emit()

func _hit(damage: int = 1):
	current_health -= damage
	if current_health <= 0:
		_expire()
	else:
		get_sprite(self).texture.add_xy(damage, 0)

# May be called multiple times, use wisely
func wakeup():
	alive = true
	process_mode = Node.PROCESS_MODE_INHERIT
	current_health = health

func _enter_tree() -> void:
	wakeup()

func handle_collision(c: Node2D):
	for b in behaviours:
		b._handle_collision(c, self)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for b in behaviours:
			if inside_play_area or not b.play_area_bounded:
				b._process(self, delta)

func _ready():
	monitoring_play_area = monitoring_play_area or expire_outside_play_area
	if not Engine.is_editor_hint():
		for b in behaviours:
			if b:
				b._initialize(self)
				monitoring_play_area = monitoring_play_area or b.play_area_bounded
			else:
				print("Warning: %s: behaviours not set up properly!" % self)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not get_sprite(self):
		warnings.append("no Sprite2D")
	return warnings
