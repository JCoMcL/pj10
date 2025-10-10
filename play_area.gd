@tool
extends StaticBody2D

@export var width = 100:
	set(w):
		width = w
		setup_region()

@export var height = 100:
	set(h):
		height = h
		setup_region()

func get_polygon():
	for c in get_children():
		if c is CollisionPolygon2D:
			return c
	return null

func get_colorrect():
	for c in get_children():
		if c is ColorRect:
			return c
	return null

func set_region(w,h):
	var p = get_polygon()
	if p:
		$CollisionPolygon2D.set_polygon([
			Vector2(0,0),
			Vector2(w,0),
			Vector2(w,h),
			Vector2(0,h)
		])
	var c = get_colorrect()
	if c:
		c.size = Vector2(w,h)

func setup_region():
	set_region(width, height)

func _ready():
	setup_region()
