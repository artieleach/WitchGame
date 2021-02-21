extends Control

onready var globals = get_node("/root/GlobalVars")
onready var liquid_particles := $liquid_particles
onready var bubble_particles := $bubble_particles
onready var splash_particles := $splash_particles
onready var bottle := $bottle
onready var tween := $Tween as Tween

var cauldron_color = Color('#000000')

func _ready():
	yield(owner, "ready")
	set_color()


func set_color():
	globals.cauldron_color = Color('#000000')
	globals.cauldron_color.r = globals.current_potion_state[0] * 0.2 + 0.1
	globals.cauldron_color.g = globals.current_potion_state[1] * 0.3 + 0.3
	globals.cauldron_color.b = globals.current_potion_state[2] * 0.2 + 0.3
	globals.cauldron_color.a = globals.current_potion_state[3] * 0.2 + 0.5
	bottle.get_node("liquid").self_modulate = globals.cauldron_color
	tween.interpolate_property(liquid_particles, "color", liquid_particles.color, globals.cauldron_color, 0.3)
	tween.interpolate_property(bubble_particles, "color", bubble_particles.color, globals.cauldron_color, 0.3)
	tween.interpolate_property(splash_particles, "color", splash_particles.color, globals.cauldron_color, 0.3)
	tween.start()
