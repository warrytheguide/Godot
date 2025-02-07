extends CharacterBody2D

signal died
signal delete_body(body)

const GRAVITY: int = 2500
const JUMP_SPEED: int = -1100
const MAX_HEALTH: int = 3

var health: int = MAX_HEALTH

@onready var collision_area = $Area2D

func _ready():
	collision_area.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor() and Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_SPEED
	move_and_slide()

func _on_body_entered(body):
	match body.name:
		"Bear":
			take_damage(1)
			emit_signal("delete_body", body)
		"Bush":
			take_damage(1)
			emit_signal("delete_body", body)
	
	
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		health = 3
		died.emit()

func heal(amount: int):
	pass
