extends Control
var sfx = {}
var players = []

func _ready():
	for i in range(10):
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		players.append(new_player)
	dir_contents("res://audio/sounds/")
	

func dir_contents(path):
	var names = []
	var values = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				names.append(file_name)
				values.append(load(path + file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	for item in len(names):
		sfx[names[item]] = values[item]


func play_audio(sound: String, vol=0):
	var target
	for player in players:
		if player.playing:
			pass
		else:
			target = player
			break
	target.stream = sfx["%s.wav" % sound]
	target.volume_db = vol
	target.play()
