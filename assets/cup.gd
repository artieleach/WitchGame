extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ingredients = []
var sprite_contents = []
var contents = PoolVector2Array()
var content_colors = PoolColorArray()
var cup_code = []

const green_tea = preload("res://images/green_tea_bag.png")
const black_tea = preload("res://images/black_tea_bag.png")

func serve():
	contents = PoolVector2Array()
	content_colors = PoolColorArray()
	ingredients = []
	sprite_contents = []
	cup_code.sort()
	var output = str(cup_code).replace(", ", "")
	print(output)
	return output

# Called when the node enters the scene tree for the first time.
func add_to_drink():
	contents = PoolVector2Array()
	content_colors = PoolColorArray()
	cup_code = []
	if len(ingredients) > 16:
		ingredients.pop_back()
	var cur_height = 16
	for item in ingredients:
		var spot_a = Vector2(1 + int((cur_height - 2) / 4), cur_height)
		var spot_b = Vector2(13 - int((cur_height - 2) / 4), cur_height)
		contents.append(spot_a)
		contents.append(spot_b)
		var cur_color
		match item:
			"chocolate":
				cur_color = "#ff442800"
				cup_code += ['O']
			"honey":
				cur_color = "#aaAC783C"
				cup_code += ['H']
			"caramel":
				cur_color = "#66A08444"
				cup_code += ['R']
			"vanilla":
				cur_color = "#66E8E85C"
				cup_code += ['V']
			"strawberry":
				cur_color = "#66D07070"
				cup_code += ['T']
			"cinnamon":
				cur_color = "#ff985C28"
				cup_code += ['N']
			"sugar":
				cur_color = "#ffECECEC"
				cup_code += ['S']
			"shot":
				cur_color = "#cc442800"
				cup_code += ['X']
			"water":
				cur_color = "#557cd0ac"
				cup_code += ['W']
			"coffee":
				cur_color = "#ee280900"
				cup_code += ['C']
			"milk":
				cup_code += ['M']
				cur_color = "#ffd0d0d0"
			"black tea":
				cup_code += ['L']
			"green tea":
				cup_code += ['G']
		content_colors.append(cur_color)
		content_colors.append(cur_color)
		cur_height -= 1
	update()

func _draw():
	for item in sprite_contents:
		match item:
			"green tea":
				draw_texture(green_tea, Vector2(-2, -1))
			"black tea":
				draw_texture(black_tea, Vector2(3, -1))
	if not contents.empty():
		draw_multiline_colors(contents, content_colors)


func _on_cup_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			serve()
			add_to_drink()


