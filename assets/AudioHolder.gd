extends Control

onready var globals = get_node("/root/GlobalVars")
onready var musicplayer = get_node("MusicPlayer")

var sfx = {}
var songs = {}
var players = []

func _ready():
	for i in range(10):
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		players.append(new_player)
	dir_contents("res://audio/sounds/", sfx)
	dir_contents("res://audio/songs/", songs)
	update_volume()


func update_volume():
	for item in players:
		if not globals.sound:
			item.bus = "Master"
		else:
			item.bus = "Mute"


func dir_contents(path, type):
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
		print("artie you fucking HACK something went wrong. probably a permission thing? anyway if anyone except me sees this, publicly tell me to increase my shame.")
	for item in len(names):
		type[names[item]] = values[item]


func play_audio(sound: String, vol=0, pitch_scale=1):
	var target
	for player in players:
		if not player.playing:
			target = player
			break
	if sound in sfx:
		target.stream = sfx[sound]
		target.volume_db = vol
		target.pitch_scale = pitch_scale
		target.play()
		return target
	else:
		print('sound didnt work lmao')


func pause_audio(player):
	player.playing = false
	player.stream = null


func play_song(song: String, vol=0):
	if song in songs:
		musicplayer.stream = songs[song]
		musicplayer.volume_db = vol
		musicplayer.play()
	else:
		print('song didnt work lmao')
