extends StaticBody2D

var initial_y = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var r = randf()
	if r < 1.0 / 3.0:
		initial_y = 520
	elif r < 2.0 / 3.0:
		initial_y = 340
	else:
		initial_y = 150
	global_position.y = initial_y
	
var speed = 1000

func _process(delta):
	position.x -= speed * delta
