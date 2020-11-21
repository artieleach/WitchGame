extends TextureButton


export (String) var sprite
export (bool) var creates_drink

signal add_to_cup
signal add_sprite_to_cup

var held = 0
var targeted = false


func _ready():
	if creates_drink:
		connect("add_to_cup", owner, "_on_add_to_cup")
		connect("add_sprite_to_cup", owner, "_on_add_sprite_to_cup")
	$object_sprite.animation = sprite
	rect_size.x = $object_sprite.frames.get_frame(sprite, $object_sprite.frame).get_width()
	rect_size.y = $object_sprite.frames.get_frame(sprite, $object_sprite.frame).get_height()
	$pchoo.position.x = int(rect_size.x / 2)


func _on_clickable_item_pressed():
	disabled = true
	if creates_drink:
		match sprite:
			"green tea", "black tea":
				emit_signal("add_sprite_to_cup", sprite)
			_:
				emit_signal("add_to_cup", sprite)
		disabled = false
		ding()


func ding():
	$pchoo.frame = 0
	$pchoo.show()
	$pchoo.playing = true


func _on_pchoo_animation_finished():
	$pchoo.playing = false
	$pchoo.hide()


func _on_clickable_item_mouse_entered():
	targeted = true
	$AnimationPlayer.play("hover")


func _on_clickable_item_mouse_exited():
	targeted = false
	$AnimationPlayer.stop()
	$object_sprite.self_modulate = "#ffffff"

