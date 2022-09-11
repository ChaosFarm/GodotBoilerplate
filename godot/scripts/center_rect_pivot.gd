tool
extends Control

export(NodePath) var node
export(Vector2) var center = Vector2(0.5, 0.5)

var _node

func _ready():
	if node.is_empty():
		_node = self
	else:
		_node = get_node(node)
	
	_node.connect("resized", self, "_on_size_changed")
	_on_size_changed()


func _on_size_changed():
	_node.rect_pivot_offset = _node.rect_size * center
