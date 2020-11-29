extends ColorRect

var moving = 0
var last_checked = 0
var distance = 0
var counter
var counter_size
var grabbed = false


func _ready():
	rect_clip_content = true
	var children = get_children()
	if len(children) == 0:
		var test_child = Sprite.new()
		test_child.position = Vector2(20, 20)
		test_child.texture = load("res://images/portrait_test.png")
		add_child(test_child)
	counter = get_children()[1]
	counter_size = counter.texture.get_size().x


func _process(_delta):
	if last_checked != moving:
		distance = moving - last_checked
		if counter.rect_position.x > - distance - counter_size + rect_size.x and counter.rect_position.x < - distance:
			counter.rect_position.x += distance
		last_checked = moving
		owner.scroll_offset = counter.rect_position


func _gui_input(event):
	if event is InputEventMouseButton:
		grabbed = event.is_pressed()
		if grabbed:
			last_checked = event.position.x
	if grabbed:
		moving = event.position.x
