extends TextureButton

func _ready():
	$Label.text = name


func _on_Button_pressed():
	$Sprite.play()


func _on_Sprite_frame_changed():
	$Label.rect_position.y = $Sprite.frame
	if $Sprite.frame == 4:
		$Sprite.play("", true)

