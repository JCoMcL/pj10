extends RayCast3D

@export var Prompt : RichTextLabel
var curr_dialogue : String

var player: FirstPersonCharacter3D
func _ready() -> void:
	var p = get_parent()
	while p and p is not FirstPersonCharacter3D:
		p = p.get_parent()
	player = p

signal focused_interactable_changed(n: Node3D)
var prev_collider: Node3D
func _physics_process(delta: float) -> void:
	var collider = get_collider()
	if collider != prev_collider:
		focused_interactable_changed.emit(collider)
	prev_collider = collider
	if collider and collider is Interactable and collider.prompt_action == "interact":
		var key = collider.get_key()
		Prompt.text = collider.get_prompt()+ (" [%s]" % key) if key else ""
		if Input.is_action_just_pressed(collider.prompt_action):
			collider.interact(player)
	else:
		Prompt.text = ""
