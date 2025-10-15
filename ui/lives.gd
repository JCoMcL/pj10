@tool
extends Container

@export_tool_button("refresh") var f = refresh
@export_range(1,3,1) var scaling = 2:
	set(i):
		scaling = i
		for c in get_children():
			c.scaling = i
		refresh.call_deferred()

func refresh():
	size = Vector2.ZERO
	for c in get_children():
		print(size)
		if c is LifeContainer:
			c.setup_life()
		size.x += c.size.x
		size.y = max(size.y, c.size.y)
