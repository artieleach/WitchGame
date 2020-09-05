extends AnimatedSprite

var my_expiration
var my_type
var has_been_sorted = false

signal food_expired


func _ready():
	animation = my_type
	match my_type:
		'coffee':
			$food_expiration.wait_time = 5
			$food_expiration.start()
		'tea':
			$food_expiration.wait_time = 4
			$food_expiration.start()
		'cupcake':
			$food_expiration.wait_time = 20
			$food_expiration.start()


func _on_food_expiration_timeout():
	emit_signal("food_expired", self)
