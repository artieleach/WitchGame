extends DampedSpringJoint2D


func _physics_process(delta):
	update()

func _draw():
	if node_a and node_b:
		draw_line(get_node(node_a).position, get_node(node_b).position, "#000000")


