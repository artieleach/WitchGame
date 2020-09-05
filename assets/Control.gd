extends Control

export (PackedScene) var Clickable
export (PackedScene) var Foodstuff
export (PackedScene) var Customer

onready var dialog = get_node("Dialog")

var coffee_grounds = 5
var num_cupcakes = 0
var num_bev = 0
var inventory = []
var cup_contents = []
var seats = []
var customer_line = []
var speaker
const characters = ["Jerry", "Kitch", "Nick", "Nico", "Neith", "Kat*a", "Oskar", "Milza", "Jello", "Quote", "Fina", "Ranes", "Ivo", "Gator", "Hermione", "Rena", "Globin", "Kezz", "Wenk", "Spot"]
var drink = []
var current_cup_contents
var someone_bought_something


func _ready():
	$blackboard.hide()
	randomize()
	$Dialog.visible = true
	$backwall/coffee_grinder/object_sprite.frame = coffee_grounds
	seats = get_tree().get_nodes_in_group("seats")
	create_customer("mialeah", "CCCCCCCCCCCCCCCC")


func make_food(foodtype):
	var new_food = Foodstuff.instance()
	$backwall/coffee_grinder/object_sprite.frame = coffee_grounds
	new_food.my_type = foodtype
	new_food.connect("food_expired", self, "_on_food_expired")
	add_child(new_food)
	inventory += [new_food]
	organize_food(foodtype)


func _on_add_to_cup(item):
	$counter/cup.ingredients += [item]
	$counter/cup.add_to_drink()


func _on_add_sprite_to_cup(item):
	if not item in $counter/cup.sprite_contents:
		$counter/cup.sprite_contents += [item]
		$counter/cup.add_to_drink()
	

func organize_food(food_type):
	var num_cakes = 0
	num_cupcakes = 0
	num_bev = 0
	match food_type:
		"cupcake":
			for item in inventory:
				if item.my_type == food_type:
					item.position = Vector2($backwall/cupcakeholder.rect_position.x + 4 + (num_cakes % 3) * 5, $backwall/cupcakeholder.rect_position.y + 5 + int(num_cakes / 3) * 6)
					num_cakes += 1
					num_cupcakes += 1
		"coffee", "tea":
			for item in inventory:
				if item.my_type in ["coffee", "tea"]:
					item.position = Vector2($backwall/coffeeholder.rect_position.x + 3 + (num_cakes % 3) * 4, $backwall/coffeeholder.rect_position.y + 1 + int(num_cakes / 3) * 5)
					num_cakes += 1
					num_bev += 1


func _on_food_expired(food):
	inventory.erase(food)
	food.queue_free()


func _on_espresso_machine_pressed():
	if coffee_grounds > 0:
		coffee_grounds -= 1
		$backwall/coffee_grinder/object_sprite.frame = coffee_grounds


func _on_coffee_grinder_pressed():
	coffee_grounds = 5
	$backwall/coffee_grinder/object_sprite.frame = coffee_grounds


func _on_oven_animation_finished():
	if 6 > num_cupcakes:
		make_food("cupcake")
		$backwall/oven/object_sprite.playing = false
		$backwall/oven.ding()
		$backwall/oven/object_sprite.frame = 0


func create_customer(customer_name, customer_want):
	var new_customer = Customer.instance()
	customer_line += [new_customer]
	new_customer.name = customer_name
	new_customer.add_to_group("customers")
	new_customer.want = customer_want
	new_customer.spot_in_line = customer_line.find(new_customer)
	new_customer.target = $backwall/register
	new_customer.get_node("sprite").position = Vector2(212, 26)
	new_customer.connect("buying", self, "_on_buying")
	new_customer.connect("begin_dialog", self, "_on_dialog")
	var possible_seats = []
	for chair in seats:
		if chair.being_sat_in == false:
			possible_seats += [chair]
	possible_seats.shuffle()
	if len(possible_seats) > 0:
		new_customer.where_to_sit = possible_seats[0]
		possible_seats[0].being_sat_in = true
	else:
		new_customer.where_to_sit = null
	add_child(new_customer)


func _on_dialog(speaker, spesific_response=null):
	if spesific_response:
		dialog.initiate('%s_%s' % [speaker.name, spesific_response])
		someone_bought_something = speaker.has_item
	else:
		dialog.initiate('%s_%s' % [speaker.name, speaker.progress])
		someone_bought_something = speaker.has_item
	speaker.progress += 1


func _on_buying(buyer):
	if len($counter/cup.ingredients) == 16:
		var drink_made = $counter/cup.serve()
		buyer.has_item = true
		buyer.upset = drink_made == buyer.want
		if drink_made == buyer.want:
			buyer.emit_signal("begin_dialog", buyer, "right")
		else:
			buyer.emit_signal("begin_dialog", buyer, "wrong")


func _on_advance_dialog_pressed():
	dialog.next()


func _on_cup_pressed():
	if customer_line:
		customer_line[0].emit_signal("buying", customer_line[0])


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
	for node in get_children():
		if node.is_in_group("customers"):
			node.show()
