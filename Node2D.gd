extends Node2D


export (PackedScene) var ball
var last_checked = Vector2(0, 0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(20):
		var drop = ball.instance()
		add_child(drop)

func _process(delta):
	$KinematicBody2D.position = get_viewport().get_mouse_position()
