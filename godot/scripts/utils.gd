tool
class_name Utils
extends Node

static func reparent_node(node, new_parent, preserve_control_scale = false):
	var pos_var = "global_position" if "position" in node else "rect_global_position"
	var node_global_pos = node[pos_var] if node.is_inside_tree() else Vector2.ZERO
	var scale_var = "scale" if "scale" in node else "rect_scale"
	var node_global_scale = node[scale_var]
	
	if preserve_control_scale && node is Control:
		node_global_scale = get_control_global_scale(node)
	
	if node.get_parent():
		node.get_parent().remove_child(node)
	if new_parent:
		new_parent.add_child(node)
		node.set_owner(new_parent)
	else:
		node.set_owner(null)
		node[pos_var] = node_global_pos
	
	if preserve_control_scale && node is Control:
		var scale_diff = node_global_scale / get_control_global_scale(node)
		node.rect_scale *= scale_diff
	


static func move_node(node : Node, amount : int):
	var pos = node.get_position_in_parent()
	var parent : Node = node.get_parent()
	pos = clamp(pos + amount, 0, parent.get_child_count() - 1)
	parent.move_child(node, pos)


static func compare_floats(a, b, epsilon = 0.001):
	return abs(a - b) <= epsilon


static func move_toward_color(from, to, max_step):
	to.r = move_toward(from.r, to.r, max_step)
	to.g = move_toward(from.g, to.g, max_step)
	to.b = move_toward(from.b, to.b, max_step)
	to.a = move_toward(from.a, to.a, max_step)
	return to


static func print_array(array):
	var string = ""
	for thingie in array:
		string += str(thingie) + ", "
	print(string)


static func print_nodes_array_names(array):
	var string = ""
	for node in array:
		string += str(node.name) + ", "
	print(string)


static func print_with_stack(message : String, stack_array : Array = []):
	if stack_array.size() == 0:
		stack_array = get_stack()
	
	var stackie = message
	for entry in stack_array:
		stackie += "\n"
		stackie += "    " + str(entry.function) + "() at "
		stackie += str(entry.source) + ":" + str(entry.line)
	print(stackie)


static func create_2d_array(width, height):
	var new_array = []
	new_array.resize(width)
	for x in range(width):
		new_array[x] = []
		new_array[x].resize(height)
	return new_array


static func find_in_2d_array(array, element):
	for i in range(array.size()):
		var idx = array[i].find(element)
		if idx != -1:
			return idx
	return -1


static func get_random_element(array : Array):
	return array[randi()%array.size()]


static func is_mouse_above_control(control, check_visibility = true):
	if check_visibility && !control.visible:
		return false
	var mouse_pos = control.get_local_mouse_position()
	return mouse_pos.x > 0 && mouse_pos.x < control.rect_size.x \
		&& mouse_pos.y > 0 && mouse_pos.y < control.rect_size.y


static func center_control_pivot(node : Control):
	node.rect_pivot_offset = node.rect_size / 2


static func are_controls_overlapping(control1 : Control, control2 : Control):
	return control1.get_global_rect().intersects(control2.get_global_rect())


static func get_node_position(node):
	if "position" in node:
		return node.position
	return node.rect_position if "rect_position" in node else Vector2.ONE


static func get_node_scale(node):
	if "scale" in node:
		return node.scale
	return node.rect_scale if "rect_scale" in node else Vector2.ONE


static func get_control_global_scale(control : Control, max_depth := 5):
	var scale = control.rect_scale
	var parent = control
	for _i in max_depth:
		parent = parent.get_parent()
		if !parent:
			break
		scale *= get_node_scale(parent)
	return scale


static func coin_flip(chance = 50):
	return randi()%100 < chance


static func get_percentage(current, maximum):
	return float(current) / float(maximum)


static func format_time(seconds, show_hours = true):
	seconds = ceil(seconds)
	var hours = floor(seconds / 3600)
	seconds -= hours * 3600
	var minutes = floor(seconds / 60)
	seconds -= minutes * 60

	var time_text = ""

	if show_hours:
		if hours > 0:
			if hours < 10:
				time_text += "0"
			time_text += str(hours) + ":"
		else:
			time_text += "00:"

	if minutes > 0:
		if minutes < 10:
			time_text += "0"
		time_text += str(minutes) + ":"
	else:
		time_text += "00:"

	seconds = floor(seconds)
	if seconds < 10:
		time_text += "0"
	time_text += str(seconds)

	return time_text


static func is_desktop_platform():
	var desktop_names := [ "OSX", "Windows", "UWP", "X11" ]
	return desktop_names.find(OS.get_name()) != -1


static func get_screenshot_image(viewport : Viewport) -> Image:
	var current_data = viewport.get_texture().get_data()
	var data_size = current_data.get_size()
	current_data.resize(data_size.x, data_size.y)
	current_data.flip_y()
	var screenshot_image = Image.new()
	screenshot_image.create(data_size.x, data_size.y, current_data.has_mipmaps(), current_data.get_format())
	screenshot_image.blit_rect(current_data, Rect2(0, 0, data_size.x, data_size.y), Vector2.ZERO)
	return screenshot_image


static func get_screenshot_texture(viewport : Viewport) -> Texture:
	var screenshot_image = get_screenshot_image(viewport)
	var tex := ImageTexture.new()
	tex.create_from_image(screenshot_image)
	return tex


static func vibrate(force):
	if OS.get_name() == "Android" || OS.get_name() == "iOS":
		Input.vibrate_handheld(force)
