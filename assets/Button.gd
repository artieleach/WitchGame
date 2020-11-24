extends TextureButton


func _ready():
	$button/Label.text = name


func _on_Button_pressed():
	$AnimationPlayer.play("button_pressed")


func _on_Button_button_down():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("button_down")


func _on_Button_button_up():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("button_up")
