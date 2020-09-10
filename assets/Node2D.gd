extends Node2D


func _ready():
	pass

func _process(delta):
	position = Vector2(int(get_global_mouse_position().x), int(get_global_mouse_position().y))
