extends Node

var fsm: StateMachine

var destination

func enter():
	randomize()
	owner.get_node("sprite").frame = 0
	owner.get_node("sprite").animation = "sitting down"
	owner.get_node("sprite").play('', false)
	yield( owner.get_node("sprite"), "animation_finished" )
	owner.where_to_sit = null
	exit("walking")


func exit(next_state):
	fsm.change_to(next_state)

