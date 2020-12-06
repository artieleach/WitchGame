extends Control
var sfx = {}
var players = []

var sound_muted: bool = false

func _ready():
	for i in range(10):
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		players.append(new_player)
	dir_contents("res://audio/sounds/")
	update_volume()


func update_volume():
	for item in players:
		if not owner.sound:
			item.bus = "Master"
		else:
			item.bus = "Mute"


func dir_contents(path):
	var names = []
	var values = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav") or file_name.ends_with('.ogg'):
				names.append(file_name.split('.')[0])
				values.append(load(path + file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	for item in len(names):
		sfx[names[item]] = values[item]


func play_audio(sound: String, vol=0):
	var target
	# ??? ?????????????????
	for player in players:
		if not player.playing:
			target = player
			break
	if sound in sfx:
		target.stream = sfx[sound]
		target.volume_db = vol
		target.play()
	else:
		print('sound didnt work lmao')
