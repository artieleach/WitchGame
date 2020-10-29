extends ColorRect


var moving = 0
var last_checked = 0
var distance = 0
var counter
var click_position

func _ready():
	counter = get_children()[0]
	print(counter)

func _process(delta):
	if last_checked != moving:
		distance = (moving - last_checked) * 1.5
		if counter.rect_position.x > - distance - counter.rect_size.x + rect_size.x and counter.rect_position.x < - distance:
			counter.rect_position.x += distance
		last_checked = moving

func _input(event):
	if event is InputEventMouseButton:
		last_checked = int(event.position.x)
		click_position = int(event.position.x)
		owner.grabbed = event.is_pressed()
	if owner.grabbed:
		moving = int(event.position.x)

