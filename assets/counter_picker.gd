extends ColorRect

var moving = 0
var last_checked = 0
var distance = 0
var counter
var counter_size
var grabbed = false
const scroll_factor = 10


func _ready():
	rect_clip_content = true
	var children = get_children()
	if len(children) == 0:
		var test_child = Sprite.new()
		test_child.position = Vector2(20, 20)
		test_child.texture = load("res://images/portrait_test.png")
		add_child(test_child)
	counter = get_children()[0]
	counter_size = counter.texture.get_size().x


func _process(_delta):
	if last_checked != moving:
		distance = moving - last_checked
		counter.rect_position.x = clamp(counter.rect_position.x + distance, - counter_size + rect_size.x, 0)
		last_checked = moving
		owner.scroll_offset = counter.rect_position


func lmao(event):  #_gui_input
	if event is InputEventMouseButton:
		if event.button_index == 5:
			last_checked -= scroll_factor
		if event.button_index == 4:
			last_checked += scroll_factor
		grabbed = event.is_pressed()
		if grabbed:
			last_checked = event.position.x
	if grabbed:
		moving = event.position.x
