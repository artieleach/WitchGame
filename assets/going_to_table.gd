extends Node

var fsm: StateMachine

var destination
var dest_spot = 0

func enter():
	destination = owner.where_to_sit
	owner.get_node("sprite").animation = "walking"
	owner.get_node("sprite").play()
	owner.get_node("sprite").flip_h = not(destination.rect_position.x > owner.position.x)
	if destination.flip_h:
		dest_spot = destination.rect_position.x
	else:
		dest_spot =  destination.rect_position.x + destination.rect_size.x


func exit(next_state):
	fsm.change_to(next_state)

func process(_delta):
	if dest_spot > owner.get_node("sprite").position.x:
			owner.get_node("sprite").position.x += owner.speed
	else:
		exit("sit_down")

