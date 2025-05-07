extends StaticBody2D

var speed = 1000
var sped_up = false
var initial_y = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	initial_y = 340 if randf() < 0.5 else 520
	global_position.y = initial_y
	


func _process(delta):
	position.x -= speed * delta
