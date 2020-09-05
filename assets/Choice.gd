extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal clicked_innit


func _on_Choice_meta_clicked(meta):
	emit_signal("clicked_innit", meta)
