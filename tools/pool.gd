extends Object
class_name Pool

var store: Array[Node]
var counter = 0:
	set(i):
		while i >= store.size() and i > 0:
			i -= store.size()
		counter = i

var _verbose: bool
var _overdraft_behaviour: int
var _scene: PackedScene
var _default_search = 0

enum Poolmode {EXPAND, WAIT, RECYCLE, PASS}

func warn(s):
	if _verbose:
		push_warning("Warning: " + s)

func return_to_pool(n: Node):
	n.get_parent().remove_child(n)

func add(n: Node) -> Node:
	assert( "expire" in n and n.expire is Signal)
	n.expire.connect(return_to_pool.bind(n))
	if "auto_free" in n and n.auto_free is bool:
		n.auto_free = false
	store.append(n)
	return n

func _init(scn: PackedScene, count: int=2, overdraft_behaviour=Poolmode.EXPAND, use_search=true, verbose=true):
	_scene=scn
	_overdraft_behaviour=overdraft_behaviour
	_verbose=verbose
	assert(count > 0)
	for i in range(count):
		var n = scn.instantiate()
		add(n)
	_default_search = store.size() if use_search else 0

func next(parent: Node, search=_default_search) -> Node:
	var n = store[counter] if store else null
	if not is_instance_valid(n):
		warn("Warning: a node has been deleted")
		store.pop_at(counter)
		return await next(parent)
	counter += 1

	if n and n.is_inside_tree():
		if search > 0:
			return await next(parent, search-1)
		warn("Warning: pool member %s is still active. Consider increasing allocation to at least %d" % [n, store.size() + 1])
		match _overdraft_behaviour:
			Poolmode.EXPAND:
				n = add(_scene.instantiate())
			Poolmode.WAIT:
				await n.expire
			Poolmode.RECYCLE:
				pass
			Poolmode.PASS:
				return null

	if parent:
		if n.is_inside_tree():
			n.reparent(parent)
		else:
			parent.add_child(n)
	return n
