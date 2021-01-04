extends TextureButton
signal clicked

func _ready():
	connect("clicked", owner, "_on_%s_pressed" % name)
	$button/Label.text = name
	$button.flip_h = bool(randi() % 2)


func _on_Button_pressed():
	$AnimationPlayer.play("button_pressed")
	owner.audioholder.play_audio("bookFlip2", -20)


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("clicked")
