extends Control


func _ready():
	$SceneTransition.transition({"Direction": "in", "Destination": "Menu"})


func _on_Credits_pressed():
	$SceneTransition.transition({"Direction": "out", "Destination": "Credits"})


func _on_Options_pressed():
	$SceneTransition.transition({"Direction": "out", "Destination": "Options"})


func _on_Play_pressed():
	$Tween.interpolate_property($AudioStreamPlayer, "volume_db", $AudioStreamPlayer.volume_db, -80.0, 0.3)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Game"})
