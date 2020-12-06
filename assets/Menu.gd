extends Control
var sound = false
var music = false
onready var audioholder = get_node("AudioHolder")

func _ready():
	$SceneTransition.transition({"Direction": "in", "Destination": "Menu"})

func _on_Credits_pressed():
	$Tween.interpolate_property($AudioStreamPlayer, "volume_db", $AudioStreamPlayer.volume_db, -80.0, 0.3)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Credits"})


func _on_Options_pressed():
	$Tween.interpolate_property($AudioStreamPlayer, "volume_db", $AudioStreamPlayer.volume_db, -80.0, 0.3)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Options"})


func _on_Play_pressed():
	$Tween.interpolate_property($AudioStreamPlayer, "volume_db", $AudioStreamPlayer.volume_db, -80.0, 0.3)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Game"})
