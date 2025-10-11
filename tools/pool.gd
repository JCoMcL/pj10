extends Object
class_name Pool

var store = []
var counter = 0:
	set(i):
		while i >= store.size():
			i -= store.size()
		counter = i

func add(n: Node):
	if "pma" in n and n.pma is MemberAttributes:
		n.pma.active = false
	else:
		push_warning("Warning, no MemberAttributes in node: %s, active and inactive state must by managed manually" % n)
	store.append(n)

func _init(scn: PackedScene, count: int = 2, parent: Node = null):
	for i in range(count):
		var n = scn.instantiate()
		add(n)
		if parent:
			parent.add_child.call_deferred(n)


func next() -> Node:
	var n = store[counter]
	if n.pma.active:
		push_warning("Warning: pool member %s is still active")
	n.pma.active = true
	counter += 1
	return n

class MemberAttributes:
	var _owner_restore_process_mode: Node.ProcessMode
	var owner: Node:
		set(n):
			_owner_restore_process_mode = n.process_mode
			owner = n

	var active = false:
		set(b):
			active = b
			if "visible" in owner:
				owner.visible = b
			if b:
				owner.process_mode = _owner_restore_process_mode
			else:
				_owner_restore_process_mode = owner.process_mode
				owner.process_mode = Node.PROCESS_MODE_DISABLED

	func _init(_owner: Node, default_active = true):
		owner = _owner
		active = default_active

