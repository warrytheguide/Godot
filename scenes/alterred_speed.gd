extends StaticBody2D

var speed = 850
var sped_up = false

func _ready():
	var main_node = get_tree().get_root().get_node("Main")
	if main_node.is_hardmode:
		speed *= 2


func _process(delta):
	position.x -= speed * delta
