extends Control

export (PackedScene) var Label

var num_of_items = 0
var num_of_children = 0
var drinks
const offset = Vector2(10, 10)
const item_height = 15



func _ready():
	yield (owner, "ready")
	var file = File.new()
	file.open('res://dialog/drinks.json', file.READ)
	var json = file.get_as_text()
	drinks = JSON.parse(json).result
	file.close()
	for drink in drinks:
		generate_item(drink)


func generate_item(menu_item):
	var menu_item_label = Label.instance()
	$blackboard_texture.add_child(menu_item_label)
	menu_item_label.rect_position = Vector2(offset.x, num_of_items * offset.y + offset.y)
	menu_item_label.bbcode_text = '[color=%s][url=%s]%s[/url][/color]' % [drinks[menu_item]["color"], menu_item, menu_item]
	menu_item_label.rect_size = Vector2(100, 12)
	menu_item_label.name = menu_item
	menu_item_label.add_to_group("donothide")
	menu_item_label.connect("clicked_innit", self, "_on_button_pressed")
	menu_item_label.mouse_filter = MOUSE_FILTER_STOP
	num_of_items += 1
	num_of_children = 0


func generate_child(parent, child_text, colour="423934"):
	var menu_item_entry = Label.instance()
	add_child(menu_item_entry)
	menu_item_entry.rect_position = Vector2(121, num_of_children * 80 + offset.y)
	menu_item_entry.rect_size = Vector2(120, 212)
	menu_item_entry.bbcode_text = "[color=#%s]%s[/color]" % [colour, child_text]
	menu_item_entry.add_to_group(parent.name)
	menu_item_entry.mouse_filter = MOUSE_FILTER_IGNORE
	num_of_children += 1


func _on_button_pressed(meta):
	var recipe
	for node in get_children():
		if not node.is_in_group("donothide"):
			node.queue_free()
	for node in get_children():
		if node.name == meta:
			recipe = node
	for ingredient in drinks[meta]["ingredients"]:
		generate_child(recipe, ingredient)
	generate_child(recipe, drinks[meta]["description"], "e8cc7c")
	num_of_children = 0


func _on_x_button_pressed():
	hide()

