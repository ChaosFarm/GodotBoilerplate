extends Node

signal shake_finished

export(bool) var horizontal = true
export(bool) var vertical = true

onready var timer = 0
onready var damped = true

var original_position : Vector2
var shaken_position : Vector2
var total_time
var intensity


func _ready():
	if "position" in get_parent():
		original_position = get_parent().position
	else:
		original_position = get_parent().rect_position


func _process(delta):
	if timer > 0:
		timer -= delta
		if timer <= 0:
			emit_signal("shake_finished")
			stop()
		else:
			var v = timer / total_time
			if !damped:
				v = 1
			var shakeX = 0
			if horizontal:
				shakeX = rand_range(-intensity, intensity) * v
			var shakeY = 0
			if vertical:
				shakeY = rand_range(-intensity, intensity) * v
			
			var current_position : Vector2
			if "position" in get_parent():
				current_position = get_parent().position
			else:
				current_position = get_parent().rect_position
			
			if (current_position - shaken_position).length() > 0.1:
				original_position = current_position
	
			shaken_position = original_position + Vector2(shakeX, shakeY)
			if "position" in get_parent():
				get_parent().position = shaken_position
			else:
				get_parent().rect_position = shaken_position

func shake(time, _intensity):
	if timer > 0:
		stop()
	
	timer = time
	total_time = time
	intensity = _intensity


func stop():
	timer = 0
	if "position" in get_parent():
		get_parent().position = original_position
	else:
		get_parent().rect_position = original_position
