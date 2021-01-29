extends RigidBody2D

export var mouse_drag_scale = 20
var _is_picked = false

func _input_event(viewport, event, shape_idx):
	if _event_is_left_click(event):
		_is_picked = event.pressed

func _input(event):
	 if _event_is_left_click(event) and not event.pressed:
		 _is_picked = false

func _event_is_left_click(event):
	return event is InputEventMouseButton and event.button_index == BUTTON_LEFT

func _integrate_forces(state):
	if _is_picked:
		state.linear_velocity = get_global_mouse_position() - global_position
		state.linear_velocity *= mouse_drag_scale
