extends Node

var scheduled_customers
var current_potion_state
var day
var sound
var music
var time_left
var forbidden_items = []

func ready():
	load_game()


func save():
	var save_dict = {
		"scheduled_customers": scheduled_customers,
		"current_potion_state": current_potion_state,
		"day": day,
		"sound": sound,
		"music": music,
		"forbidden_items": forbidden_items
	}
	return save_dict


func save_to_disk():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()


func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		for i in node_data.keys():
			set(i, node_data[i])
	save_game.close()
