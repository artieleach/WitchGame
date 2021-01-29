extends Control

export (PackedScene) var Customer

const potion_vars = ['A', 'B', 'C', 'D']
const DEBUG = false

onready var audioholder = get_node("/root/AudioHolder")
onready var globals = get_node("/root/GlobalVars")

onready var dialog = get_node("Dialog")
onready var counter = get_node("Scrolling_Window/counter")
onready var cauldron = get_node("Scrolling_Window/Cauldron")
onready var spellbook = get_node("Spellbook")
onready var animator = get_node("AnimationPlayer")
onready var backwall = get_node("backwall")

signal reset_ingredients

var customer_line = []
var speaker
var someone_bought_something
var customers
var scheduled_customers = []
var day: int = 1
var potion_ingredients
var scroll_offset: Vector2 = Vector2(0, 0)
var can_drop_potions: bool = false
var paused: bool = false
var time_left: int = 0
var ingredients


func _ready():
	globals.load_game()
	$SceneTransition.transition({"Direction": "in", "Destination": "Game"})
	if DEBUG:
		$FPS.show()
	randomize()
	potion_ingredients = get_json('res://assets/ingredient_data.json')
	customers = get_json('res://dialog/Characters.json')
	set_indicators(true)
	start_day()
	emit_signal("ready")
	ingredients = get_tree().get_nodes_in_group("ingredient")
	audioholder.update_volume()
	audioholder.play_audio("bubbles", -10)
	for i in range(1):
		generate_recipe()


func generate_recipe():
	var ing_copy = ingredients
	ing_copy.shuffle()
	var output = [1, 1, 1, 1]
	var potion_recipe = ing_copy.slice(0, randi() % 3 + 2)
	for i in range(len(potion_recipe)):
		output = calculate_metric(potion_recipe[i].name, output)
	print(output, potion_recipe)


func get_json(file_string):
	var cur_file = File.new()
	cur_file.open(file_string, cur_file.READ)
	var json = cur_file.get_as_text()
	var result = JSON.parse(json).result
	cur_file.close()
	return result


func _on_ingredient_pressed(ingredient):
	spellbook.get_node("book_texture/Label").text = ingredient
	spellbook.get_node("book_texture/RichTextLabel").text = potion_ingredients[ingredient]["description"]
	spellbook.get_node("book_texture/Label").set("custom_colors/font_color", potion_ingredients[ingredient]["color"])
	spellbook.show()


func _on_potion_splash(ingredient):
	cauldron.get_node("poof_particles").restart()
	cauldron.get_node("splash_particles").restart()
	cauldron.get_node("poof_particles").self_modulate = potion_ingredients[ingredient]["color"]


func _on_add_to_potion(ingredient):
	globals.current_potion_state = calculate_metric(ingredient, globals.current_potion_state)
	yield(get_tree().create_timer(0.9), "timeout")
	set_indicators()


func _on_check_effects(ingredient):
	for i in range(len(globals.current_potion_state)):
		counter.get_node(ingredient).helpers.get_node("%s/a" % potion_vars[i]).frame = potion_ingredients[ingredient]["features"][i] + 1


func set_indicators(muted=false):
	for i in range(len(globals.current_potion_state)):
		var current = cauldron.get_node("HBoxContainer/%s/indicator" % potion_vars[i]).frame
		var new = globals.current_potion_state[i]
		if not muted:
			if current > new:
				audioholder.play_audio('down', -4)
			if current < new:
				audioholder.play_audio('up', -4)
			if current == new:
				audioholder.play_audio('stay', -2)
		cauldron.get_node("HBoxContainer/%s/indicator" % potion_vars[i]).frame = new
		yield(get_tree().create_timer(0.2), "timeout")


func calculate_metric(ingredient, cur_state):
	var new_state = [0, 0, 0, 0]
	for i in range(len(cur_state)):
		new_state[i] = clamp(cur_state[i] + potion_ingredients[ingredient]["features"][i], 0, 2)
	return new_state


func create_customer(customer):
	var new_customer = Customer.instance()
	backwall.add_child(new_customer)
	new_customer.set_owner(self)
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
	animator.play("customer_entered")


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
	$end_of_day/end_day_summary.text = "Witching Hour is over.\nDay %d" % day
	for customer in get_tree().get_nodes_in_group("customers"):
		customer.queue_free()
	$end_of_day.show()
	$Tween.interpolate_property($end_of_day, "color:a", 0, 1, 0.5)
	$Tween.interpolate_property($end_of_day/end_day_summary, "self_modulate:a", 0, 1, 0.5, 0, 2, 1)
	$Tween.start()
	$Timer.time_left = 766
	day += 1


func start_day():
	$Timer.wait_time = 766
	$Timer.start()
	scheduled_customers = customers.keys()
	scheduled_customers.shuffle()
	scheduled_customers = scheduled_customers.slice(0, 13)
	scheduled_customers = ['kitch', 'kitch', 'kitch']
	$end_of_day.mouse_filter = Control.MOUSE_FILTER_STOP
	if DEBUG:
		create_customer(scheduled_customers[0])


func _on_end_of_day_gui_input(event):
	globals.save_to_disk()
	if event is InputEventMouseButton:
		$end_of_day.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Tween.interpolate_property($end_of_day, "color:a", 1, 0, 0.5)
		$Tween.interpolate_property($end_of_day/end_day_summary, "self_modulate:a", 1, 0, 0.5, 0, 2)
		$Tween.start()
		yield($Tween, "tween_completed")
		start_day()
		$end_of_day.hide()


func audio_passer(name: String, volume= 0):
	audioholder.play_audio(name, volume)


func _on_Control_tree_exiting():
	globals.save_to_disk()
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


func _on_button_toggled(button_pressed):
	globals.music = $OptionsMenu.Music.pressed
	globals.sound = $OptionsMenu.Sound.pressed
	if button_pressed == "Menu":
		globals.save_to_disk()
		$SceneTransition.transition({"Direction": "out", "Destination": "Menu"})
	audioholder.update_volume() # whats up future artie. past you is bad at programming so these values are flipped.


func _on_burger_pressed():
	$blackboard.hide()
	$Spellbook.hide()
	$OptionsMenu.slide()
	get_tree().paused = true


func _on_next_customer_timer_timeout():
	check_next_customer()
