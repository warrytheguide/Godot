extends StaticBody2D

var speed = 850  # Speed in pixels per second

func _process(delta):
	position.x -= speed * delta
