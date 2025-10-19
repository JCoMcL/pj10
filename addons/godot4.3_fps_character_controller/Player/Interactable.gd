class_name Interactable extends Node

signal interacted(body)

@export var relay_interact: Node

@export_subgroup("Dialogue")
@export_file("*.json") var dialouge : String


@export_category("Prompt Settings")
@export_enum(
	"interact",
	"text",
	) var prompt_action : String = "interact"
@export_multiline var prompt_message : String = "Interact"
@export var prompt_key_override : bool = false
@export_multiline var override_text : String = ""

@export var _hasDialogue : bool = false

var _dialogue_parsed : Dictionary
var _dialogue_index : int = 1

func _ready() -> void:
	if dialouge != "":
		_parse_dialogue()


func get_key() -> String:
	if prompt_key_override:
		return override_text
	else:
		for action in InputMap.action_get_events(&"interact"):
			if action is InputEventKey:
				return action.as_text_physical_keycode()
			elif action is InputEventMouseButton:
				return mouse_button_to_string(action.button_index)
	return ""

func mouse_button_to_string(button: MouseButton) -> String:
	match button:
		MouseButton.MOUSE_BUTTON_LEFT:
			return "LMB"
		MouseButton.MOUSE_BUTTON_RIGHT:
			return "RMB"
		MouseButton.MOUSE_BUTTON_MIDDLE:
			return "MMB"
		MouseButton.MOUSE_BUTTON_WHEEL_UP:
			return "Wheel Up"
		MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			return "Wheel Down"
		MouseButton.MOUSE_BUTTON_WHEEL_LEFT:
			return "Wheel Left"
		MouseButton.MOUSE_BUTTON_WHEEL_RIGHT:
			return "Wheel Right"
		MouseButton.MOUSE_BUTTON_XBUTTON1:
			return "Extra Button 1"
		MouseButton.MOUSE_BUTTON_XBUTTON2:
			return "Extra Button 2"
		_:
			return "Unknown Button"

func get_prompt() -> String:
	return prompt_message

func interact(body) -> void:
	if body.has_method("_interact"):
		body._interact(relay_interact if relay_interact else self)
	interacted.emit(body)

func run_dialogue() -> void:
	_dialogue_index += 1
	if _dialogue_index > _dialogue_parsed["Dialogue"].size():
		reset_current_dialogue()
	prompt_message = _dialogue_parsed["Dialogue"]["%s"%[_dialogue_index]]["Text"]

func reset_current_dialogue() -> void:
	_dialogue_index = 1

func _parse_dialogue() -> void:
	_hasDialogue = true
	var file = FileAccess.open(dialouge, FileAccess.READ)
	if file.get_open_error() != OK:
		printerr("Error opening file")
		return
	var data = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(data)
	if err == OK:
		_dialogue_parsed = json.get_data()
		print(_dialogue_parsed["Dialogue"])

	file.close()
