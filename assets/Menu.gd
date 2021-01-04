extends Control

onready var audioholder: Node = get_node("/root/AudioHolder")

var sound = false
var music = false
var bg_player

func _ready():
	audioholder.play_song("magic-forest-by-kevin-macleod-from-filmmusic-io")
	$SceneTransition.transition({"Direction": "in", "Destination": "Menu"})


func _on_Credits_pressed():
	audioholder.pause_audio(audioholder.musicplayer)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Credits"})


func _on_Options_pressed():
	audioholder.pause_audio(audioholder.musicplayer)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Options"})


func _on_Play_pressed():
	audioholder.pause_audio(audioholder.musicplayer)
	$Tween.start()
	$SceneTransition.transition({"Direction": "out", "Destination": "Game"})
