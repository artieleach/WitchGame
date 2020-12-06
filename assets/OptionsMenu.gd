extends Control

onready var Menu = get_node("Book/VBoxContainer/Menu")
onready var Music = get_node("Book/VBoxContainer/Music")
onready var Sound = get_node("Book/VBoxContainer/Sound")

signal button_toggled
var button_pressed

func _ready():
	yield(owner, "ready")
	connect("button_toggled", owner, "_on_button_toggled")
	Music.pressed = owner.music
	Sound.pressed = owner.sound
	for item in [Music, Sound]:
		if item.pressed:
			item.modulate = Color("8b93af")
		else:
			item.modulate = Color("141013")


func _on_Menu_pressed():
	emit_signal("button_toggled", "Menu")
	slide()


func _on_Music_pressed():
	if Music.pressed:
		Music.modulate = Color("8b93af")
	else:
		Music.modulate = Color("141013")
	emit_signal("button_toggled", "Music")


func _on_Sound_pressed():
	if Sound.pressed:
		Sound.modulate = Color("8b93af")
	else:
		Sound.modulate = Color("141013")
	emit_signal("button_toggled", "Sound")


func slide():
	if $Book.position.x == -212:
		show()
		$Tween.interpolate_property($Book, "position:x", $Book.position.x, -150, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	else:
		$Tween.interpolate_property($Book, "position:x", $Book.position.x, -212, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	if $Book.position.x == -212:
		get_tree().paused = false
		hide()



func _on_OptionsMenu_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		slide()
