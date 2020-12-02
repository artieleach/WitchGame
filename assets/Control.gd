extends Control

export (PackedScene) var Customer
export (PackedScene) var Ingredient

const potion_vars = ['A', 'B', 'C', 'D']
const DEBUG = true
onready var dialog = get_node("Dialog")
onready var counter = get_node("Scrolling_Window/counter")
onready var cauldron = get_node("Scrolling_Window/Cauldron")
onready var spellbook = get_node("Spellbook")

var cup_contents = []
var seats = []
var customer_line = []
var speaker
var drink = []
var current_cup_contents
var someone_bought_something
var customers
var scheduled_customers = []
var sound: bool = true
var music: bool = true
var grabbed: bool = false
var day: int = 1
var potion_ingredients
var scroll_offset: Vector2 = Vector2(0, 0)
var can_drop_potions: bool = false
var current_potion_state = [1, 1, 1, 1]
var paused: bool = false
var time_left: int = 766


func _ready():
	load_game()
	$SceneTransition.transition({"Direction": "in", "Destination": "Game"})
	if DEBUG:
		$FPS.show()
	randomize()
	potion_ingredients = get_json('res://dialog/Potions.json')
	seats = get_tree().get_nodes_in_group("seats")
	start_day()
	emit_signal("ready")


func get_json(file_string):
	var cur_file = File.new()
	cur_file.open(file_string, cur_file.READ)
	var json = cur_file.get_as_text()
	var result = JSON.parse(json).result
	cur_file.close()
	if result == null:
		print(file_string)
	return result


func save():
	var save_dict = {
		"time_left": $Timer.time_left,
		"scheduled_customers": scheduled_customers,
		"current_potion_state": current_potion_state,
		"day": day
	}
	return save_dict


func save_to_disk():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()
	var out_file = File.new()
	out_file.open('res://dialog/Characters.json', out_file.WRITE)
	var out = JSON.print(customers, '  ')
	out_file.store_line(out)


func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		for i in node_data.keys():
			set(i, node_data[i])
			print(i, node_data[i])
	save_game.close()
	customers = get_json('res://dialog/Characters.json')
	set_indicators()


func _on_ingredient_pressed(ingredient):
	$Spellbook/Label.text = ingredient.name
	$Spellbook/RichTextLabel.text = potion_ingredients[ingredient.name]["description"]
	$Spellbook/Label.set("custom_colors/font_color", potion_ingredients[ingredient.name]["color"])
	$Spellbook.show()


func _on_potion_splash(ingredient):
	cauldron.get_node("poof_particles").restart()
	cauldron.get_node("splash_particles").restart()
	cauldron.get_node("poof_particles").self_modulate = potion_ingredients[ingredient.name]["color"]
	cauldron.get_node("poof_particles").emitting = true
	cauldron.get_node("splash_particles").emitting = true


func _on_add_to_potion(ingredient):
	for i in range(len(current_potion_state)):
		current_potion_state[i] = clamp(current_potion_state[i] + potion_ingredients[ingredient.name]["features"][i], 0, 2)
		cauldron.get_node("HBoxContainer/%s/indicator" % potion_vars[i]).frame = current_potion_state[i]


func _on_check_effects(ingredient):
	for i in range(len(current_potion_state)):
		ingredient.helpers.get_node("%s/a" % potion_vars[i]).frame = potion_ingredients[ingredient.name]["features"][i] + 1


func set_indicators():
	for i in range(len(current_potion_state)):
		cauldron.get_node("HBoxContainer/%s/indicator" % potion_vars[i]).frame = current_potion_state[i]


func create_customer(customer):
	var new_customer = Customer.instance()
	customer_line += [new_customer]
	new_customer.name = customer
	new_customer.add_to_group("customers")
	new_customer.progress = customers[customer]["progress"]
	new_customer.mistakes = customers[customer]["mistakes"]
	new_customer.want = customers[customer]["drink"][new_customer.progress]
	new_customer.spot_in_line = customer_line.find(new_customer)
	new_customer.target = $backwall/register
	new_customer.get_node("sprite").position = $backwall/exit.rect_position
	new_customer.connect("buying", self, "_on_buying")
	new_customer.connect("begin_dialog", self, "_on_dialog")
	$backwall.add_child(new_customer)


func _on_dialog(cur_speaker, spesific_response=null):
	if spesific_response:
		dialog.initiate('%s/%s' % [cur_speaker.name, spesific_response])
	else:
		dialog.initiate('%s/%s_%s' % [cur_speaker.name, cur_speaker.name, cur_speaker.progress])
	someone_bought_something = cur_speaker.has_item
	cur_speaker.progress += 1


func _on_advance_dialog_pressed():
	dialog.next()


func _on_Dialog_block_ended():
	if someone_bought_something:
		if customer_line[0].where_to_sit:
			customer_line[0].change_to("going_to_table")
		else:
			customer_line[0].change_to("walking")
		customer_line.erase(customer_line[0])
		someone_bought_something = false


func _on_blackboard_pressed():
	for node in get_children():
		if node.is_in_group("customers"):
			node.hide()
	$blackboard.show()


func _on_x_button_pressed():
	for node in get_tree().get_nodes_in_group("customers"):
		node.show()


func _process(_delta):
	if DEBUG:
		$FPS.text = str(int(Performance.get_monitor(0)))


func check_next_customer():
	if len(customer_line) == 0 and $Timer.time_left > 66:
		customers.pop()
		create_customer(customers[0])
	$next_customer_timer.wait_time = randi() % 25 + 5
	$next_customer_timer.start()


func end_day():
	$end_of_day/end_day_summary.text = "Another day, another dollar.\nDay %d" % day
	for customer in get_tree().get_nodes_in_group("customers"):
		customer.queue_free()
	$end_of_day.show()
	$Tween.interpolate_property($end_of_day, "color:a", 0, 1, 0.5)
	$Tween.interpolate_property($end_of_day/end_day_summary, "self_modulate:a", 0, 1, 0.5, 0, 2, 1)
	$Tween.start()
	time_left = 766
	day += 1


func start_day():
	$Timer.wait_time = time_left
	$Timer.start()
	scheduled_customers = customers.keys()
	scheduled_customers.shuffle()
	scheduled_customers = scheduled_customers.slice(0, 13)
	scheduled_customers = ['kitch', 'kitch', 'kitch']
	$end_of_day.mouse_filter = Control.MOUSE_FILTER_STOP
	if DEBUG:
		create_customer(scheduled_customers[0])


func _on_end_of_day_gui_input(event):
	save_to_disk()
	if event is InputEventMouseButton:
		$end_of_day.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Tween.interpolate_property($end_of_day, "color:a", 1, 0, 0.5)
		$Tween.interpolate_property($end_of_day/end_day_summary, "self_modulate:a", 1, 0, 0.5, 0, 2)
		$Tween.start()
		yield($Tween, "tween_completed")
		start_day()
		$end_of_day.hide()


func _on_Control_tree_exiting():
	save_to_disk()
	var out_file = File.new()
	out_file.open('res://dialog/Characters.json', out_file.WRITE)
	var out = JSON.print(customers, '  ')
	out_file.store_line(out)
	out_file.close()


func _on_Timer_timeout():
	if not $Dialog/Frame.visible:
		end_day()
	else:
		$Timer.wait_time = 30
		$Timer.start()


func _on_chair_clear(previous_owner):
	for chair in seats:
		if chair.being_sat_in == previous_owner:
			chair.being_sat_in = false


func _on_button_toggled(button_pressed):
	if button_pressed == "Menu":
		save_to_disk()
		$SceneTransition.transition({"Direction": "out", "Destination": "Menu"})


func _on_burger_pressed():
	$blackboard.hide()
	$Spellbook.hide()
	$OptionsMenu.slide()


func _on_next_customer_timer_timeout():
	check_next_customer()
