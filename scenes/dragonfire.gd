extends StaticBody2D

var initial_y = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	initial_y = 340 if randf() < 0.5 else 520
	global_position.y = initial_y
	
var speed = 1000

func _process(delta):
	position.x -= speed * delta
