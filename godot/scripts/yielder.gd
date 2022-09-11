extends Node

signal cleared()

var _timers := []


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func wait(duration):
	var new_timer = Timer.new()
	add_child(new_timer)
	new_timer.start(float(duration))
	_timers.append(new_timer)
	return new_timer


func finish_last_timer() -> bool:
	if _timers.size() > 0:
		_timers.pop_back().emit_signal("timeout")
		return true
	return false


func finish_timer(timer):
	_timers.erase(timer)
	timer.emit_signal("timeout")


func clear():
	for timer in _timers:
		timer.queue_free()
	_timers.clear()
	emit_signal("cleared")
