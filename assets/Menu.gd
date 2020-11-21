extends Control


func _ready():
	pass


func _on_Credits_pressed():
	$SceneTransition.transition({"Direction": "out", "Destination": "Credits"})


func _on_Options_pressed():
	$SceneTransition.transition({"Direction": "out", "Destination": "Options"})


func _on_Play_pressed():
	$SceneTransition.transition({"Direction": "out", "Destination": "Game"})

