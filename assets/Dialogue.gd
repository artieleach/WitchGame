extends Control

onready var dialogue = get_node("Dialogue")
onready var choice_holder = get_node("choice_holder")
var chosen_option : int = 0


func _ready():
	dialogue.start_dialogue()
	choice_holder.hide()
	for i in range(4):
		choice_holder.get_node("%d" % i).connect("pressed", self, "_on_option_pressed")


func _on_option_pressed(choice):
	chosen_option = choice


func _on_Dialogue_Dialogue_Next(ref, actor, text):
	$RichTextLabel.show()
	$RichTextLabel.text = text


func _on_Dialogue_Choice_Next(ref, choices):
	choice_holder.show()
	$RichTextLabel.hide()
	for i in range(4):
		if i < len(choices):
			choice_holder.get_node("%d" % i).show()
			choice_holder.get_node("%d/Label" % i).text = choices[i]["Dialogue"]
		else:
			choice_holder.get_node("%d" % i).hide()


func _on_DialogueHolder_gui_input(event):
	if event is InputEventMouseButton and  event.button_index == BUTTON_LEFT:
		dialogue.next_dialogue()
