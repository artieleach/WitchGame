extends Node

var fsm: StateMachine

var destination
var dest_pos = 0

func enter():
	destination = owner.where_to_sit
	owner.get_node("sprite").animation = "walking"
	owner.get_node("sprite").play()
	owner.get_node("sprite").flip_h = not(destination.rect_position.x > owner.position.x)
	if destination.flip_h:
		dest_pos = destination.rect_position.x
	else:
		dest_pos =  destination.rect_position.x + destination.rect_size.x


func exit(next_state):
	fsm.change_to(next_state)

func process(delta):
	var currnet_pos =  owner.get_node("sprite").position.x
	if destination.rect_position.x + owner.spot_in_line * 10 + dest_pos > owner.get_node("sprite").position.x:
		owner.get_node("sprite").position.x += owner.speed * delta
	elif destination.rect_position.x + destination.rect_size.x + owner.spot_in_line * 10  + dest_pos < owner.get_node("sprite").position.x:
		owner.get_node("sprite").position.x -= owner.speed * delta
	else:
		exit("sit down")
