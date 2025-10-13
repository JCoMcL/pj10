extends Object
class_name Pool

var store: Array[Node]
var counter = 0:
	set(i):
		while i >= store.size():
			i -= store.size()
		counter = i

var _verbose: bool
var _overdraft_behaviour: int
var _scene: PackedScene
var _default_search = 0

enum {EXPAND, WAIT, RECYCLE, PASS}

func warn(s):
	if _verbose:
		push_warning("Warning: " + s)

func return_to_pool(n: Node):
	n.get_parent().remove_child(n)

func add(n: Node) -> Node:
	assert( "expire" in n and n.expire is Signal)
	n.expire.connect(return_to_pool.bind(n))
	if "auto_expire" in n and n.auto_expire is bool:
		n.auto_expire = false
	store.append(n)
	return n

func _init(scn: PackedScene, count: int = 2, overdraft_behaviour = EXPAND, use_search=true, verbose=true):
	_scene=scn
	_overdraft_behaviour=overdraft_behaviour
	_verbose=verbose
	for i in range(count):
		var n = scn.instantiate()
		add(n)
	_default_search = store.size() if use_search else 0

func next(parent: Node, search=_default_search) -> Node:
	var n = store[counter]
	if not is_instance_valid(n):
		warn("Warning: a node has been deleted")
		store.pop_at(counter)
		return await next(parent)
	counter += 1

	if n.is_inside_tree():
		if search > 0:
			return await next(parent, search-1)
		warn("Warning: pool member %s is still active. Consider increasing allocation to at least %d" % [n, store.size() + 1])
		match _overdraft_behaviour:
			EXPAND:
				n = add(_scene.instantiate())
			WAIT:
				await n.expire
			RECYCLE:
				pass
			PASS:
				return null

	if parent:
		if n.is_inside_tree():
			n.reparent(parent)
		else:
			parent.add_child(n)
	return n
