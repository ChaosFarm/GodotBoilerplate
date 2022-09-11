class_name TintButton
extends TextureButton

export(Color) var normal_color = Color(1, 1, 1, 1.0)
export(Color) var hover_color = Color(1, 1, 1, 1.0)
export(Color) var pressed_color = Color(0.7, 0.7, 0.7, 1.0)
export(Color) var disabled_color = Color(0.7, 0.7, 0.7, 1.0)
export(Color) var disabled_hover_color = Color(0.8, 0.8, 0.8, 1.0)
export(bool) var modulate_self = false
export(NodePath) var modulated_node
export(float) var color_transition_speed = 0

export(NodePath) var neighbour_up
export(NodePath) var neighbour_down
export(NodePath) var neighbour_left
export(NodePath) var neighbour_right

var currently_pressed : bool = false
var currently_hovered : bool = false
var disabled_last_frame : bool = false

var _target_color : Color = normal_color
var _modulated_node : CanvasItem = null


func _ready():
	
	_modulated_node = get_node_or_null(modulated_node)
	
	currently_pressed = false
	connect("visibility_changed", self, "_on_visibility_changed")
	connect("button_down", self, "_on_pressed")
	connect("button_up", self, "_on_released")
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")
	connect("focus_exited", self, "_mouse_exited")
	connect("focus_entered", self, "_focus_entered")
	if disabled:
		_set_color(disabled_color)
	elif has_focus():
		_set_color(hover_color)
	else:
		_set_color(normal_color)
	
	focus_neighbour_bottom = neighbour_down
	focus_neighbour_left = neighbour_left
	focus_neighbour_right = neighbour_right
	focus_neighbour_top = neighbour_up
	if focus_neighbour_bottom.is_empty(): focus_neighbour_bottom = get_path()
	if focus_neighbour_left.is_empty(): focus_neighbour_left = get_path()
	if focus_neighbour_right.is_empty(): focus_neighbour_right = get_path()
	if focus_neighbour_top.is_empty(): focus_neighbour_top = get_path()


func _process(delta):
	if color_transition_speed > 0:
		var color_var = _get_modulate_var()
		get_modulated_node()[color_var] = Utils.move_toward_color(self[color_var], _target_color, delta * color_transition_speed)
	
	_update_disabled_color()


func _on_visibility_changed():
	if disabled:
		_set_color(disabled_color)
	elif has_focus():
		_set_color(hover_color)
		
		if !visible:
			_move_focus_to_neighbour()
	else:
		_set_color(normal_color)	


func _update_disabled_color():
	if disabled != disabled_last_frame:
		disabled_last_frame = disabled
		if disabled:
			if currently_hovered:
				_set_color(disabled_hover_color)
			else:
				_set_color(disabled_color)
		else:
			if currently_hovered:
				_set_color(hover_color)
			else:
				_set_color(normal_color)


func _move_focus_to_neighbour():
	if focus_neighbour_left != get_path():
		get_node(focus_neighbour_left).grab_focus()
	elif focus_neighbour_right != get_path():
		get_node(focus_neighbour_right).grab_focus()
	elif focus_neighbour_top != get_path():
		get_node(focus_neighbour_top).grab_focus()
	elif focus_neighbour_bottom != get_path():
		get_node(focus_neighbour_bottom).grab_focus()


func _on_pressed():
	if disabled:
		return
	_set_color(pressed_color)
	currently_pressed = true


func _on_released():
	if disabled:
		return
	if currently_hovered:
		_set_color(hover_color)
	else:
		_set_color(normal_color)
	currently_pressed = false


func _mouse_entered():
	if disabled:
		return
	currently_hovered = true
	if currently_pressed:
		_set_color(pressed_color)
	else:
		if disabled:
			_set_color(disabled_hover_color)
		else:
			_set_color(hover_color)


func _mouse_exited():
	if disabled:
		return
	currently_hovered = false
	if disabled:
		_set_color(disabled_color)
	else:
		_set_color(normal_color)


func _focus_entered():
	if disabled:
		return
	if !visible:
		_move_focus_to_neighbour()
	else:
		_mouse_entered()


func _set_color(new_color):
	_target_color = new_color
	if color_transition_speed <= 0:
		get_modulated_node()[_get_modulate_var()] = new_color


func get_modulated_node():
	if _modulated_node:
		return _modulated_node
	return self


func _get_modulate_var():
	return "self_modulate" if modulate_self else "modulate"
