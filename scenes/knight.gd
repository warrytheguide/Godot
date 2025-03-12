extends StaticBody2D

signal spawn_obs(obs, x, y)
# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the initial position
	position = Vector2(1300, 455)  # Adjust these values as needed
	
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()  # Example shape
	area.add_child(collision_shape)
	add_child(area)
	area.monitoring = true
	area.monitorable = true
	area.connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node2D) -> void:
	if body.name == "SwordSpawner":
		print("hellye")
		var sword = load("res://scenes/sword.tscn").instantiate()
		emit_signal("spawn_obs", sword, 700, 500)
