extends Control


func _ready():
	$SceneTransition.transition({"Direction": "in", "Destination": "Game"})

func _on_transition_finished():
	$SceneTransition.hide()


func _on_TextureButton_pressed():
	$SceneTransition.show()
	$SceneTransition.transition({"Direction": "out", "Destination": "Menu"})
