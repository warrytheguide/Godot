extends CharacterBody2D

var speed = 250.0
var sped_up = false
@export var vertical_amplitude = 100.0
@export var vertical_frequency = 3.0

signal spawn_obs(obs, x, y)
signal hit_player

var time = 0.0
var initial_y = 0.0

@onready var area_2d = $Dragon
 
func _ready():

	initial_y = 370 if randf() < 0.5 else 270
	
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
	global_position.x -= speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("hit_player")
		visible = false
		$Dragon.set_deferred("monitoring", false)
		$Dragon.set_deferred("monitorable", false)
	elif body.name == "FireSpawner":
		var fire = load("res://scenes/dragonfire.tscn").instantiate()
		emit_signal("spawn_obs", fire, 800, 300)
