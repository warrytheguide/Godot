extends StaticBody2D

var speed = 150

func _ready():

	position = Vector2(1300, 455)
	
	
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	area.add_child(collision_shape)
	add_child(area)
	area.monitoring = true
	area.monitorable = true
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position.x -= speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "DevilTrigger":
		speed *= 7
