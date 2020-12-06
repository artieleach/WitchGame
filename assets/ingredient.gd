extends TextureButton

onready var ingredient_sprite = get_node("drawing/ingredient_sprite")
onready var label = get_node("drawing/Label")
onready var helpers = get_node("drawing/helpers")

var held: bool = false
var offset: Vector2 = Vector2(0, 0)
var will_open_help: bool = false
var ingredient_effects
var pickale: bool = true
var hovering_over_cauldron: bool = false
signal double_clicked
signal added_to_potion
signal potion_splash
signal check_effects


func _ready():
	yield(owner, "ready")
	connect("double_clicked", owner, "_on_ingredient_pressed", [self])
	connect("potion_splash", owner, "_on_potion_splash", [self])
	connect("added_to_potion", owner, "_on_add_to_potion", [self])
	connect("check_effects", owner, "_on_check_effects", [self])
	ingredient_sprite.texture = load("res://images/ingredients/%s.png" % name)
	ingredient_sprite.normal_map = load("res://images/ingredients/%s_NM.png" % name)
	label.text = name
	rect_size = ingredient_sprite.texture.get_size()
	label.margin_right = ingredient_sprite.texture.get_width()
	helpers.rect_size = rect_size
	texture_normal = null
	ingredient_sprite.show()
	emit_signal("check_effects")

func _process(_delta):
	if held:
		$Tween.interpolate_property($drawing, "position", $drawing.position, get_global_mouse_position() - offset - rect_position - owner.scroll_offset - Vector2(1, 42), 0.09)
		$Tween.start()


func _on_ingredient_mouse_exited():
	will_open_help = true
	label.hide()
	helpers.hide()


func reset():
	$AnimationPlayer.stop()
	ingredient_sprite.self_modulate = Color(1, 1, 1)
	emit_signal("added_to_potion")
	$drawing.z_index = 0
	$Tween.interpolate_property($drawing, "position", Vector2(0, -100), Vector2(0, 0), 1.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
	held = false
	will_open_help = false
	label.hide()
	helpers.hide()
	offset = Vector2(0, 0)


func go_back():
	$AnimationPlayer.stop()
	ingredient_sprite.self_modulate = Color(1, 1, 1)
	helpers.hide()
	offset = Vector2(0, 0)
	$Tween.interpolate_property($drawing, "position", $drawing.position, Vector2(0, 0), 0.5, Tween.TRANS_CUBIC)
	$Tween.interpolate_property($drawing, "z_index", $drawing.z_index, 0, 0.5)
	$Tween.start()


func pick_up():
	ingredient_sprite.self_modulate = Color(1, 1, 1)
	label.hide()
	held = true
	$drawing.z_index = 5
	$Tween.interpolate_property(self, "offset", offset, ingredient_sprite.texture.get_size() / 2, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


func add_to_potion():
	$AnimationPlayer.stop()
	ingredient_sprite.self_modulate = Color(1, 1, 1)
	helpers.hide()
	$drawing.z_index = 2
	$Tween.interpolate_property($drawing, "position:y", $drawing.position.y, 50, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(0.4), "timeout")
	emit_signal("potion_splash")


func mouse_hover():
	label.show()
	helpers.show()


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			hide()
			emit_signal("double_clicked")
			yield(get_tree().create_timer(0.2), "timeout")
			show()
		elif event.button_index == BUTTON_LEFT:
			if event.pressed:
				offset = event.position 
				pick_up()
			else:
				label.hide()
				helpers.hide()
				held = false
				if get_global_mouse_position().x > 185 and get_global_mouse_position().x < 185+16:
					add_to_potion()
				else:
					go_back()
	if event is InputEventMouseMotion:
		if held:
			hovering_over_cauldron = get_global_mouse_position().x > 185 and get_global_mouse_position().x < 185+16
			if hovering_over_cauldron:
				$AnimationPlayer.play("hovering_over_potion")
			elif $AnimationPlayer.current_animation == "hovering_over_potion":
				$AnimationPlayer.stop()
				ingredient_sprite.self_modulate = Color(1, 1, 1)
		else:
			$AnimationPlayer.stop()
			mouse_hover()


func _on_Tween_tween_completed(object, key):
	pickale = true
	if object == $drawing and key == ":position:y":
		reset()
