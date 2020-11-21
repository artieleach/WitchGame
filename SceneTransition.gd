extends Control

var cur_trans: Dictionary = {"Direction": "in", "Destination": "game"}


func transition(trans_type):
	show()
	cur_trans = trans_type
	if trans_type["Direction"] == "out":
		$Tween.interpolate_property($ColorRect, "color:a", 0, 1, 0.75)
	else:
		$Tween.interpolate_property($ColorRect, "color:a", 1, 0, 0.6)
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	if object == $ColorRect:
		hide()
		transition_finished()

func transition_finished():
	if cur_trans["Direction"] == 'out':
		if cur_trans["Destination"] == "Game":
			get_tree().change_scene("res://assets/main.tscn")
		elif cur_trans["Destination"] == "Credits":
			get_tree().change_scene("res://assets/credits.tscn")
		elif cur_trans["Destination"] == "Menu":
			get_tree().change_scene("res://assets/Menu.tscn")
		elif cur_trans["Destination"] == "Options":
			pass

