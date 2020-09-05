extends Node

var fsm: StateMachine

var destination

func enter():
	destination = owner.where_to_sit
	owner.get_node("sprite").frame = 0
	owner.get_node("sprite").animation = "sitting down"
	owner.get_node("sprite").flip_h = destination.flip_h
	print(destination.flip_h, destination)
	owner.get_node("sprite").play()
	yield( owner.get_node("sprite"), "animation_finished" )
	#exit("waiting")


func exit(next_state):
	fsm.change_to(next_state)

