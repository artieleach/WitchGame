extends AudioStreamPlayer
var songs = []

func _ready():
	songs = [
		load("res://audio/airport-lounge-by-kevin-macleod.wav"),
		load("res://audio/bossa-antigua-by-kevin-macleod.wav"),
		load("res://audio/george-street-shuffle-by-kevin-macleod.wav"),
		]
	_on_AudioStreamPlayer_finished()



func _on_AudioStreamPlayer_finished():
	stream = songs[randi() % 3]
	play()

