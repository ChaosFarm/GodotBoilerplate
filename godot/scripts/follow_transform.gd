extends Node

export(NodePath) var target_node
export(bool) var follow_position = true
export(bool) var follow_rotation = true
export(bool) var follow_scale = true

onready var _target_node = get_node(target_node)



func _process(delta):
	if !_target_node:
		return
	
	if follow_position:
		self[_get_position_var_name(self)] = _target_node[_get_position_var_name(_target_node)]
	if follow_rotation:
		self[_get_rotation_var_name(self)] = _target_node[_get_rotation_var_name(_target_node)]
	if follow_scale:
		self[_get_scale_var_name(self)] = _target_node[_get_scale_var_name(_target_node)]

func _get_position_var_name(node):
	return _get_var_name(node, "position", "_rect_position")

func _get_scale_var_name(node):
	return _get_var_name(node, "scale", "_rect_scale")

func _get_rotation_var_name(node):
	return _get_var_name(node, "rotation", "_rect_rotation")

func _get_var_name(node, option1, option2):
	if node.get("option1"):
		return option1
	return option2
