extends Node2D

class_name StateMachine

const DEBUG = false

var state: Object

var history = []

signal buying
signal begin_dialog

var progress
var my_name
var want
var has_item = false
var target
var where_to_sit
var exit
var spot_in_line
var upset
var mistakes



func _ready():
	exit = get_tree().get_nodes_in_group("exit")[0]
	state = get_child(0)
	call_deferred("_enter_state")


func change_to(new_state):
	history.append(state.name)
	state = get_node(new_state)
	_enter_state()


func back():
	if history.size() > 0:
		state = get_node(history.pop_back())
		_enter_state()


func _enter_state():
	if DEBUG:
		print("Entering state: ", state.name)
		printt(history)
	# Give the new state a reference to it's state machine i.e. this one
	state.fsm = self
	state.enter()


func _process(delta):
	if state.has_method("process"):
		state.process(delta)

