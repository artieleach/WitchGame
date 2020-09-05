extends Node


var from
var to
var color

func set_lines(_from, _to):
	from = _from
	to = _to

func _draw():
	draw_line(from, to, color)
