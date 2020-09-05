extends Node

var fsm: StateMachine

func enter():
	owner.get_node("sprite").animation = "waiting"

func exit(next_state):
	fsm.change_to(next_state)
