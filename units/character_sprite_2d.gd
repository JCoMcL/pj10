@tool
extends Sprite2D
class_name CharacterSprite2D

var atlas: HandyAtlas

func _ready() -> void:
	if not texture:
		texture = HandyAtlas.new()
		texture.resource_local_to_scene = true
	atlas = texture

