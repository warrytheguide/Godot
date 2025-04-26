extends CharacterBody2D

@export var horizontal_speed = 200.0
@export var vertical_amplitude = 170.0
@export var vertical_frequency = 5.0

signal spawn_obs(obs, x, y)
signal hit_player

var time = 0.0
var initial_y = 0.0

@onready var area_2d = $Dragon
 
func _ready():

	var r = randf()
	initial_y = 200
	if r < 1.0 / 3.0:
		initial_y = 350
	elif r < 2.0 / 3.0:
		initial_y = 250
	else:
		initial_y = 150
	
	global_position.y = initial_y
	
	if area_2d:
		area_2d.monitoring = true
		area_2d.monitorable = true
		area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("Error: Dragon Area2D node not found")

func _physics_process(delta):
	time += delta
	
	var vertical_movement = sin(time * vertical_frequency) * vertical_amplitude
	
	global_position.y = initial_y + vertical_movement
	global_position.x -= horizontal_speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("hit_player")
		visible = false
		$Dragon.set_deferred("monitoring", false)
		$Dragon.set_deferred("monitorable", false)
	elif body.name.begins_with("DevilFireSpawner"):
		var fire = load("res://scenes/devilfire.tscn").instantiate()
		emit_signal("spawn_obs", fire, global_position.x, 300)
