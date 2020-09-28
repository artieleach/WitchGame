extends Node

var fsm: StateMachine

var destination
var dest_pos = 0

func enter():
	destination = owner.target
	if owner.has_item:
		destination = owner.where_to_sit
	if not destination:
		destination = owner.exit
	if destination.rect_position.x + owner.spot_in_line * 10 > owner.get_node("sprite").position.x or destination.rect_position.x + destination.rect_size.x + owner.spot_in_line * 10 < owner.get_node("sprite").position.x:
		owner.get_node("sprite").animation = "walking"
		owner.get_node("sprite").play()
		owner.get_node("sprite").flip_h = destination.rect_position.x < owner.get_node("sprite").position.x


func exit(next_state):
	fsm.change_to(next_state)


func process(delta):
	if destination.rect_position.x + owner.spot_in_line * 10 + dest_pos > owner.get_node("sprite").position.x:
		owner.get_node("sprite").position.x += owner.speed * delta
	elif destination.rect_position.x + destination.rect_size.x + owner.spot_in_line * 10  + dest_pos < owner.get_node("sprite").position.x:
		owner.get_node("sprite").position.x -= owner.speed * delta
	else:
		if destination in get_tree().get_nodes_in_group("seats"):
			exit("sit_down")
		elif not owner.has_item and owner.spot_in_line == 0:
			exit("buy_item")
		elif not owner.has_item:
			exit("waiting")
		elif destination in get_tree().get_nodes_in_group("exit"):
			owner.queue_free()

