extends AudioStreamPlayer
var songs = []

func _ready():
	pass



func _on_AudioStreamPlayer_finished():
	stream = songs[randi() % 3]
	play()




