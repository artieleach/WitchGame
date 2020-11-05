extends ColorRect


var moving = 0
var last_checked = 0
var distance = 0
var counter
var click_position
var counter_size


func _ready():
	rect_clip_content = true
	counter = get_children()[0]
	counter_size = counter.texture.get_size().x

func _process(delta):
	if last_checked != moving:
		distance = moving - last_checked
		if counter.position.x > - distance - counter_size + rect_size.x and counter.position.x < - distance:
			counter.position.x += distance
		last_checked = moving


func _input(event):
	if event is InputEventMouseButton:
		last_checked = event.position.x
		click_position = event.position.x
		owner.grabbed = event.is_pressed()
	if owner.grabbed:
		moving = event.position.x

