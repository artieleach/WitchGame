extends TextureButton



export (int) var cook_time
export (String) var sprite
export (bool) var creates_food
export (bool) var creates_drink

signal add_to_cup
signal add_sprite_to_cup

var held = 0
var times_held = 0
var targeted = false


func _ready():
	if creates_drink:
		connect("add_to_cup", owner, "_on_add_to_cup")
		connect("add_sprite_to_cup", owner, "_on_add_sprite_to_cup")
	$cook_timer.wait_time = cook_time
	$cook_timer.start()
	$object_sprite.animation = sprite
	rect_size.x = $object_sprite.frames.get_frame(sprite, $object_sprite.frame).get_width()
	rect_size.y = $object_sprite.frames.get_frame(sprite, $object_sprite.frame).get_height()
	$pchoo.position.x = int(rect_size.x / 2)


func _process(delta):
	if targeted and Input.is_mouse_button_pressed(1):
		held += 1 * delta
		if held > 0.3 - times_held:
			_on_clickable_item_pressed()
			held = 0
			if times_held < 0.25:
				times_held += 0.05


func _on_clickable_item_pressed():
	disabled = true
	match sprite:
		"oven", "kettle":
			$object_sprite.frame = 0
			$object_sprite.playing = true
			disabled = true
		_:
			ding()
	if creates_drink:
		match sprite:
			"green tea", "black tea":
				emit_signal("add_sprite_to_cup", sprite)
			_:
				emit_signal("add_to_cup", sprite)
		disabled = false


func ding():
	$pchoo.show()
	$pchoo.frame = 0
	$pchoo.playing = true


func _on_cook_timer_timeout():
	disabled = false


func _on_pchoo_animation_finished():
	$pchoo.hide()


func _on_clickable_item_mouse_entered():
	held = 0
	times_held = 0
	targeted = true
	$AnimationPlayer.play("hover")


func _on_clickable_item_mouse_exited():
	held = 0
	times_held = 0
	targeted = false
	$AnimationPlayer.stop()
	$object_sprite.self_modulate = "#ffffff"

