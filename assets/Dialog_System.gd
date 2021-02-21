"""
Godot Open dialog - Non-linear conversation system
Author: J. Sena
Version: 1.2
License: CC-BY
URL: https://jsena42.bitbucket.io/god/
Repository: https://bitbucket.org/jsena42/godot-open-dialog/
"""

extends Control

##### SETUP #####
onready var globals = get_node("/root/GlobalVars")
onready var audioholder: Node = get_node("/root/AudioHolder")
## Paths ##
var dialogs_folder = 'res://dialog' # Folder where the JSON files will be stored
var choice_scene = load('res://assets/Choice.tscn') # Base scene for que choices
## Required nodes ##
onready var frame : Node = $Frame # The container node for the dialogs.
onready var label : Node = $Frame/advance/RichTextLabel # The label where the text will be displayed.
onready var choices : Node = $Frame/Choices # The container node for the choices.
onready var timer : Node = $Timer # Timer node.
onready var continue_indicator : Node = $ContinueIndicator # Blinking square displayed when the text is all printed.
onready var animations : Node = $AnimationPlayer
onready var sprite_left : Node = $SpriteLeft # Used for showing the avatar on the dialog
onready var advance : Node = $Frame/advance
## Typewriter effect ##
var wait_time : float = 0.03 # Time interval (in seconds) for the typewriter effect. Set to 0 to disable it. 
var pause_time : float = 2.0 # Duration of each pause when the typewriter effect is active.
var pause_char : String = '|' # The character used in the JSON file to define where pauses should be. If you change this you'll need to edit all your dialog files.
var newline_char : String = '@' # The character used in the JSON file to break lines. If you change this you'll need to edit all your dialog files.
## Other customization options ##
onready var progress = PROGRESS # The AutoLoad script where the interaction log, quest variables, inventory and other useful data should be acessible.
var dialogs_dict = 'dialogs' # The dictionary on 'progress' used to keep track of interactions.

var active_choice : Color = Color(1.0, 1.0, 1.0, 1.0)
var inactive_choice : Color = Color(1.0, 1.0, 1.0, 0.4)
var flip_flop = true


signal dialog_ingredient_pressed

var previous_command : String = 'ui_up' # Input commmand for the navigating through question choices 
var next_command : String = 'ui_down' # Input commmand for the navigating through question choices

var enable_continue_indicator : bool = true # Enable or disable the 'continue_indicator' animation when the text is completely displayed. If typewritter effect is disabled it will always be visible on every dialog block.

# END OF SETUP #

# Default values. Don't change them unless you really know what you're doing.
var id
var next_step = ''
var dialog
var phrase = ''
var phrase_raw = ''
var current = ''
var number_characters : = 0
var dictionary

var is_question : = false
var current_choice : = 0
var number_choices : = 0

var pause_index : = 0
var paused : = false
var pause_array : = []






#
onready var sprite_timer : Node = $SpriteTimer
onready var tween : Node = $Tween

var white_opaque = Color(1.0, 1.0, 1.0, 1.0)
var white_transparent = Color(1.0, 1.0, 1.0, 0.0)
var black_opaque = Color(0.0, 0.0, 0.0, 1.0)
var black_transparent = Color(0.0, 0.0, 0.0, 0.0)
var light_gray_opaque = Color(0.75, 0.75, 0.75, 1.0)

var mirrored_sprite = 'right'

var shake_base = 20
var move_distance = 100
var ease_in_speed = 0.25
var ease_out_speed = 0.25

var characters_folder = 'res://images/portraits'
var characters_image_format = 'png'

var previous_pos
var sprite

var on_tween = false

var shake_amount

var shake_weak = 1
var shake_regular = 2
var shake_strong = 4

var shake_short = 0.25
var shake_medium = 0.5
var shake_long = 2

var on_animation : bool = false

var avatar_left : String = ''
var avatar_right : String = ''

var shaking : bool = false

func _ready():
	connect("dialog_ingredient_pressed", owner, "bring_ingredient")
	set_physics_process(true)
	timer.connect('timeout', self, '_on_Timer_timeout')
	sprite_timer.connect('timeout', self, '_on_Sprite_Timer_timeout')
	set_frame()
	if globals.debug or true:
		initiate("petra_redo")


func _physics_process(delta):
	if shaking:
		sprite.offset = Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount)


func set_frame(): # Mostly aligment operations.
	frame.hide() # Hide the dialog frame
	continue_indicator.hide()
	sprite_left.modulate = white_transparent


func initiate(file_id, block = 'first'): # Load the whole dialog into a variable
	id = file_id
	var file = File.new()
	file.open('%s/%s.json' % [dialogs_folder, id], file.READ)
	print('%s/%s.json' % [dialogs_folder, id])
	var json = file.get_as_text()
	dialog = JSON.parse(json).result
	file.close()
	first(block) # Call the first dialog block

#func start_from(file_id, block): # Similar to 

func clean(): # Resets some variables to prevent errors.
	continue_indicator.hide()
	animations.stop()
	paused = false
	pause_index = 0
	pause_array = []
	current_choice = 0
	timer.wait_time = wait_time # Resets the typewriter effect delay
	advance.show()
	choices.hide()


func not_question():
	is_question = false


func first(block):
	frame.show()
	if block == 'first': # Check if we are going to use the default 'first' block
		if dialog.has('repeat'):
			if progress.get(dialogs_dict).has(id): # Checks if it's the first interaction.
				update_dialog(dialog['repeat']) # It's not. Use the 'repeat' block.
			else:
				progress.get(dialogs_dict)[id] = true # Updates the singleton containing the interactions log.
				update_dialog(dialog['first']) # It is. Use the 'first' block.
		else:
				update_dialog(dialog['first'])
	else: # We are going to use a custom first block
		update_dialog(dialog[block])


func update_dialog(step): # step == whole dialog block
	clean()
	current = step
	number_characters = 0 # Resets the counter
	# Check what kind of interaction the block is
	match step['type']:
		'text': # Simple text.
			not_question()
			label.bbcode_text = step['content']
			check_pauses(label.get_text())
			check_newlines(phrase_raw)
			clean_bbcode(step['content'])
			number_characters = phrase_raw.length()
			check_animation(step)
			
			if step.has('next'):
				next_step = step['next']
			else:
				next_step = ''
				
		'divert': # Simple way to create complex dialog trees
			not_question()
			print(step['true'])
			match step['condition']:
				'boolean':
					if progress.get(step['dictionary']).has(step['variable']):
						if progress.get(step['dictionary'])[step['variable']]:
							next_step = step['true']
						else:
							next_step = step['false']
					else:
						next_step = step['false']
				'equal':
					if progress.get(step['dictionary']).has(step['variable']):
						if progress.get(step['dictionary'])[step['variable']] == step['value']:
							next_step = step['true']
						else:
							next_step = step['false']
					else:
						next_step = step['false']
				'greater':
					if progress.get(step['dictionary']).has(step['variable']):
						if progress.get(step['dictionary'])[step['variable']] > step['value']:
							next_step = step['true']
						else:
							next_step = step['false']
					else:
						next_step = step['false']
				'less':
					if progress.get(step['dictionary']).has(step['variable']):
						if progress.get(step['dictionary'])[step['variable']] < step['value']:
							next_step = step['true']
						else:
							next_step = step['false']
					else:
						next_step = step['false']
				'range':
					if progress.get(step['dictionary']).has(step['variable']):
						if progress.get(step['dictionary'])[step['variable']] > (step['value'][0] - 1) and progress.get(step['dictionary'])[step['variable']] < (step['value'][1] + 1):
							next_step = step['true']
						else:
							next_step = step['false']
					else:
						next_step = step['false']
			next()
			
		'question': # Moved to question() function to make the code more readable.
			label.bbcode_text = step['text']
			question(step['text'], step['options'], step['next'])
			check_newlines(phrase_raw)
			clean_bbcode(step['text'])
			check_animation(step)
			number_characters = phrase_raw.length()
			next_step = step['next'][0]
			choices.show()
			advance.hide()
			
		'action':
			not_question()
			
			match step['operation']:
				'variable':
					update_variable(step['value'], step['dictionary'])
					if step.has('next'):
						next_step = step['next']
					else:
						next_step = ''
				'random':
					randomize()
					next_step = step['value'][randi() % step['value'].size()]
			
			if step.has('text'):
				label.bbcode_text = step['text']
				check_pauses(label.get_text())
				check_newlines(phrase_raw)
				clean_bbcode(step['text'])
				number_characters = phrase_raw.length()
				check_animation(step)
			else:
				label.visible_characters = number_characters
				next()
	
	if wait_time > 0: # Check if the typewriter effect is active and then starts the timer.
		label.visible_characters = 0
		timer.start()
	elif enable_continue_indicator: # If typewriter effect is disabled check if the ContinueIndicator should be displayed
		continue_indicator.show()
		animations.play('Continue_Indicator')


func check_pauses(string):
	var next_search = 0
	phrase_raw = string
	next_search = phrase_raw.find('%s' % pause_char, next_search)
	
	if next_search >= 0:
		while next_search != -1:
			pause_array.append(next_search)
			phrase_raw.erase(next_search, 1)
			next_search = phrase_raw.find('%s' % pause_char, next_search)


func check_newlines(string):
	var line_search = 0
	var line_break_array = []
	var pause_array_backup = pause_array
	var new_pause_array = []
	var current_line = 0
	phrase_raw = string
	line_search = phrase_raw.find('%s' % newline_char, line_search)
	
	if line_search >= 0:
		while line_search != -1:
			line_break_array.append(line_search)
			phrase_raw.erase(line_search,1)
			line_search = phrase_raw.find('%s' % newline_char, line_search)
	
		for a in pause_array_backup.size():
			if pause_array_backup[a] > line_break_array[current_line]:
				current_line += 1
			new_pause_array.append(pause_array_backup[a]-current_line)
				
		pause_array = new_pause_array


func clean_bbcode(string):
	phrase = string
	var pause_search = 0
	var line_search = 0
	
	pause_search = phrase.find('%s' % pause_char, pause_search)
	
	if pause_search >= 0:
		while pause_search != -1:
			phrase.erase(pause_search,1)
			pause_search = phrase.find('%s' % pause_char, pause_search)
	
	phrase = phrase.split('%s' % newline_char, true, 0) # Splits the phrase using the newline_char as separator
	
	var counter = 0
	label.bbcode_text = ''
	for n in phrase:
		label.bbcode_text = label.get('bbcode_text') + phrase[counter] + '\n'
		counter += 1


func next(x=0):
	if not dialog or on_animation: # Check if is in the middle of a dialog 
		return
	clean() # Be sure all the variables used before are restored to their default values.
	if wait_time > 0: # Check if the typewriter effect is active.
		if label.visible_characters < number_characters: # Checks if the phrase is complete.
			label.visible_characters = number_characters # Finishes the phrase.
			return # Stop the function here.
	else: # The typewriter effect is disabled so we need to make sure the text is fully displayed.
		label.visible_characters = -1 # -1 tells the RichTextLabel to show all the characters.
	if next_step == '': # Doesn't have a 'next' block.
		if current.has('animation_out'):
			animate_sprite(current['position'], current['avatar'], current['animation_out'])
			yield(tween, "tween_completed")
		else:
			sprite_left.modulate = white_transparent
		dialog = null
		frame.hide()
		avatar_left = ''
		avatar_right = ''
	else:
		label.bbcode_text = ''
		if choices.get_child_count() > 0: # If has choices, remove them.
			for n in choices.get_children():
				choices.remove_child(n)
		else:
			pass
		if current.has('animation_out'):
			animate_sprite(current['position'], current['avatar'], current['animation_out'])
			yield(tween, "tween_completed")
		
		update_dialog(dialog[next_step])


func check_animation(block):
	if block.has('avatar') and block.has('animation_in'):
		animate_sprite(block['position'], block['avatar'], block['animation_in'])
	return


func animate_sprite(direction, image, animation):
	var current_pos
	var move_vector
	
	sprite = sprite_left
	current_pos = sprite.position
	
	move_vector = Vector2(current_pos.x - move_distance, current_pos.y)
	
	previous_pos = current_pos
	
	match animation:
		
		'shake_weak_short':
			shake_amount = shake_weak
			sprite_timer.wait_time = shake_short
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_weak_medium':
			shake_amount = shake_weak
			sprite_timer.wait_time = shake_medium
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_weak_long':
			shake_amount = shake_weak
			sprite_timer.wait_time = shake_long
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_regular_short':
			shake_amount = shake_regular
			sprite_timer.wait_time = shake_short
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_regular_medium':
			shake_amount = shake_regular
			sprite_timer.wait_time = shake_medium
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_regular_long':
			shake_amount = shake_regular
			sprite_timer.wait_time = shake_long
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_strong_short':
			shake_amount = shake_strong
			sprite_timer.wait_time = shake_short
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_strong_medium':
			shake_amount = shake_strong
			sprite_timer.wait_time = shake_medium
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'shake_strong_long':
			shake_amount = shake_strong
			sprite_timer.wait_time = shake_long
			sprite_timer.start()
			on_animation = true
			shaking = true
			set_physics_process(true)
			
		'fade_in':
			load_image(sprite, image)
			tween.interpolate_property(sprite, 'modulate',
					white_transparent, white_opaque, ease_in_speed/1.25,
					Tween.TRANS_QUAD, Tween.EASE_IN)
					
			sprite_timer.wait_time = ease_in_speed/1.25
			tween.start()
			sprite_timer.start()
			on_animation = true
			
		'fade_out':
			tween.interpolate_property(sprite, 'modulate',
					white_opaque, white_transparent, ease_out_speed/1.25,
					Tween.TRANS_QUAD, Tween.EASE_OUT)
					
			sprite_timer.wait_time = ease_out_speed/1.25
			tween.start()
			sprite_timer.start()
			on_animation = true
			
		'move_in':
			load_image(sprite, image)
			tween.interpolate_property(sprite, 'position',
					move_vector, current_pos, ease_in_speed,
					Tween.TRANS_QUINT, Tween.EASE_IN)
					
			tween.interpolate_property(sprite, 'modulate',
					white_transparent, white_opaque, ease_in_speed,
					Tween.TRANS_QUINT, Tween.EASE_IN)
					
			sprite_timer.wait_time = ease_in_speed
			tween.start()
			sprite_timer.start()
			on_animation = true
			
		'move_out':
			tween.interpolate_property(sprite, 'position',
					current_pos, move_vector, ease_out_speed,
					Tween.TRANS_BACK, Tween.EASE_OUT)
					
			tween.interpolate_property(sprite, 'modulate',
					white_opaque, black_transparent, ease_out_speed,
					Tween.TRANS_QUINT, Tween.EASE_OUT)
					
			sprite_timer.wait_time = ease_out_speed
			tween.start()
			sprite_timer.start()
			on_animation = true
		
		'on':
			tween.interpolate_property(sprite, 'modulate',
					light_gray_opaque, white_opaque, ease_in_speed,
					Tween.TRANS_QUAD, Tween.EASE_IN)
					
			sprite_timer.wait_time = ease_in_speed
			tween.start()
			sprite_timer.start()
			on_animation = true
			
		'off':
			tween.interpolate_property(sprite, 'modulate',
					white_opaque, light_gray_opaque, ease_out_speed,
					Tween.TRANS_QUAD, Tween.EASE_OUT)
					
			sprite_timer.wait_time = ease_out_speed
			tween.start()
			sprite_timer.start()
			on_animation = true


func load_image(sprite, image):
	sprite.texture = load('%s/%s.png' % [characters_folder, image])


func question(text, options, next):
	check_pauses(label.get_text())
	var n = 0 
	for a in options:
		var choice = choice_scene.instance()
		choice.bbcode_text = '[url=%s]%s[/url]' % [a, a]
		choice.my_pos = n
		choice.connect("meta_hover_started", self, "update_choice", [choice])
		choice.connect("meta_clicked", self, "next")
		choice.self_modulate = inactive_choice
		choices.add_child(choice)
		n += 1
	is_question = true
	number_choices = choices.get_child_count() - 1


func change_choice(dir):
	if is_question:
		if label.visible_characters >= number_characters: # Make sure the whole question is displayed before the player can answer.
			match dir: # If you want to stop the 'loop' effect on the choices, invert the commented sections.
				'previous':
					choices.get_child(current_choice).self_modulate = inactive_choice
					current_choice = current_choice - 1 if current_choice > 0 else number_choices
					choices.get_child(current_choice).self_modulate = active_choice
				'next':
					choices.get_child(current_choice).self_modulate = inactive_choice
					current_choice = current_choice + 1 if current_choice < number_choices else 0
					choices.get_child(current_choice).self_modulate = active_choice
			next_step = current['next'][current_choice]


func update_choice(_selected_item, sender):
	current_choice = sender.my_pos
	next_step = current['next'][current_choice]
	for child in choices.get_children():
		child.self_modulate = inactive_choice
	choices.get_child(current_choice).self_modulate = active_choice


func update_variable(variables_array, current_dict):
	for n in variables_array:
		progress.get(current_dict)[n[0]] = n[1]


func _input(event): # This function can be easily replaced. Just make sure you call the function using the right parameters.
	if event.is_action_pressed('%s' % previous_command):
		change_choice('previous')
	if event.is_action_pressed('%s' % next_command):
		change_choice('next')


func play_beep():
	if flip_flop and not label.bbcode_text[label.visible_characters] in ['!', '.', ',', ' ', '?']:
		audioholder.play_audio('text', -4)
	flip_flop = not flip_flop
	if label.bbcode_text[label.visible_characters] in ['!', '.', ',', ' ', '?']:
		flip_flop = true


func _on_Timer_timeout():
	if label.visible_characters < number_characters: # Check if the timer needs to be started
		if paused:
			update_pause()
			return # If in pause, ignore the rest of the function.
		if pause_array.size() > 0: # Check if the phrase have any pauses left.
			if label.visible_characters == pause_array[pause_index]: # pause_char == index of the last character before pause.
				timer.wait_time = pause_time * wait_time * 10
				paused = true
			else:
				label.visible_characters += 1
				play_beep()
		else: # Phrase doesn't have any pauses.
			label.visible_characters += 1
			play_beep()
		timer.start()
	else:
		if is_question:
			choices.get_child(0).self_modulate = active_choice
		elif dialog and enable_continue_indicator:
			animations.play('Continue_Indicator')
			continue_indicator.show()
		timer.stop()
		return


func update_pause():
	if pause_array.size() > (pause_index+1): # Check if the current pause is not the last one. 
		pause_index += 1
	else: # Doesn't have any pauses left.
		pause_array = []
		pause_index = 0
	paused = false
	timer.wait_time = wait_time
	timer.start()


func _on_Sprite_Timer_timeout():
	sprite.position = previous_pos
	set_physics_process(false)
	on_animation = false
	shaking = false


func _on_advance_pressed():
	next()


func _on_RichTextLabel_meta_clicked(meta):
	emit_signal("dialog_ingredient_pressed", meta)

