extends AnimatedSprite


func _process(delta):
	frame = 0
	if randf() > 0.98:
		frame = randi() % 3
