extends TextureButton


func _ready():
	$button/Label.text = name
	$button.flip_h = bool(randi() % 2)


func _on_Button_pressed():
	$AnimationPlayer.play("button_pressed")
	owner.audioholder.play_audio("metalLatch", -20)
