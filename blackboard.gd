extends Control

export (PackedScene) var Label

var num_of_items = 0
var num_of_children = 0
var drinks


func initiate(): # Load the whole dialogue into a variable
	var file = File.new()
	file.open('res://dialog/drinks.json', file.READ)
	var json = file.get_as_text()
	drinks = JSON.parse(json).result
	file.close()


func _ready():
	initiate()
	for drink in drinks:
		generate_item(drink)


func generate_item(menu_item):
	var menu_item_label = Label.instance()
	add_child(menu_item_label)
	menu_item_label.rect_position = Vector2(4, num_of_items * 12 + 3)
	menu_item_label.bbcode_text = '[url=%s]%s[/url]' % [menu_item, drinks[menu_item]["drink_name"]]
	menu_item_label.rect_size = Vector2(100, 20)
	menu_item_label.name = menu_item
	menu_item_label.add_to_group("donothide")
	menu_item_label.connect("clicked_innit", self, "_on_button_pressed")
	num_of_items += 1
	num_of_children = 0
	generate_child(menu_item_label, drinks[menu_item]["description"], "e8cc7c")


func generate_child(parent, child_text, colour="fce08c"):
	var menu_item_label = Label.instance()
	add_child(menu_item_label)
	menu_item_label.rect_position = Vector2(80, num_of_children * 12 + 3)
	menu_item_label.rect_size = Vector2(120, 100)
	menu_item_label.bbcode_text = "[color=#%s]%s[/color]" % [colour, child_text]
	menu_item_label.add_to_group(parent.name)
	num_of_children += 1


func _on_button_pressed(meta):
	var recipe
	for node in get_children():
		if not node.is_in_group("donothide"):
			node.queue_free()
	for node in get_children():
		if node.name == meta:
			recipe = node
			print('here')
	for ingredient in drinks[meta]["ingredients"]:
		printt('here', meta, recipe)
		generate_child(recipe, ingredient)

	num_of_children = 0


func _on_x_button_pressed():
	hide()

