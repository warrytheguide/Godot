extends CharacterBody2D

@export var horizontal_speed = 250.0
@export var vertical_amplitude = 100.0
@export var vertical_frequency = 3.0

signal hit_player

var time = 0.0
var initial_y = 0.0

@onready var area_2d = $Bat
 
func _ready():

	initial_y = 370 if randf() < 0.5 else 270
	
	global_position.y = initial_y
	
	if area_2d:
		area_2d.monitoring = true
		area_2d.monitorable = true
		area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("Error: Bat Area2D node not found")

func _physics_process(delta):
	time += delta
	
	var vertical_movement = sin(time * vertical_frequency) * vertical_amplitude
	
	global_position.y = initial_y + vertical_movement
	global_position.x -= horizontal_speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("hit_player")
		visible = false
		$Bat.set_deferred("monitoring", false)
		$Bat.set_deferred("monitorable", false)
		
