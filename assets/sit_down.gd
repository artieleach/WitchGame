extends Node

var fsm: StateMachine

var destination

func enter():
	print(owner.get_node("sprite").position.x)
	randomize()
	destination = owner.where_to_sit
	owner.get_node("sprite").frame = 0
	owner.get_node("sprite").animation = "sitting down"
	owner.get_node("sprite").flip_h = destination.flip_h
	print(destination.flip_h, destination)
	owner.get_node("sprite").play(owner.get_node("sprite").animation, false)
	yield( owner.get_node("sprite"), "animation_finished" )
	yield(get_tree().create_timer(randi() % 120 + 60), "timeout")
	owner.get_node("sprite").speed_scale =  - 1.5
	owner.get_node("sprite").frame = -1
	owner.get_node("sprite").animation = "sitting down"
	owner.get_node("sprite").play(owner.get_node("sprite").animation, true)
	owner.emit_signal("getting_up")
	yield( owner.get_node("sprite"), "animation_finished" )
	owner.get_node("sprite").speed_scale = 1
	owner.where_to_sit = null
	exit("walking")


func exit(next_state):
	fsm.change_to(next_state)

