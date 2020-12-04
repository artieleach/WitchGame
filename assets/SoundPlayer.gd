extends AudioStreamPlayer
var sfx = {}

func _ready():
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


