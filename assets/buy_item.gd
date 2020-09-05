extends Node

var fsm: StateMachine


func enter():
	owner.emit_signal("begin_dialog", owner)
	if owner.has_item:
		owner.spot_in_line = 0
		if owner.where_to_sit and not owner.upset:
			exit("going_to_table")
		else:
			exit("walking")
	else:
		exit("waiting")


func exit(next_state):
	fsm.change_to(next_state)

