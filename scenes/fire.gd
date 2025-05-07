extends StaticBody2D

var initial_y = 0.0
var speed = 850
var sped_up = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	initial_y = 340 if randf() < 0.5 else 520
	global_position.y = initial_y
	


func _process(delta):
	position.x -= speed * delta
