extends CharacterBody2D

signal died_signal
signal delete_body_signal(body)
signal kill_score_signal(amount)

const MAX_HEALTH: int = 3
const BUFF_DURATION: float = 6
const KILL_SCORE: float = 100
const JUMP_FORCE = -700  # Adjust this value as needed
const JUMP_CUT = 0.6     # How much to cut the jump when button is released
const GRAVITY = 2500      # Adjust as needed
const MAX_JUMP_TIME = 0.3  # Maximum time the jump can be held (in seconds)

var health: int = MAX_HEALTH
var hearts_list: Array[TextureRect]

var jump_time = 0
var is_jumping = false
var double_jump = false
var drop_through = false
var drop_timer = 0.0
const DROP_DELAY = 0.04  # Adjust this value as needed

var is_honeyed: bool = false
var honeyed_buff_timer: Timer = null
var is_appled: bool = false
var appled_buff_timer: Timer = null
var is_fired: bool = false
var fired_buff_timer: Timer = null
var is_sworded: bool = false
var is_crowned: bool = false
var crowned_buff_timer: Timer = null

@onready var collision_area = $Area2D

func _ready():
	
	collision_area.body_entered.connect(_on_body_entered)
	
	var hearts_parent = $HealthBar/HBoxContainer
	
	get_parent().connect("new_game_signal", new_game)
	get_parent().connect("game_over_signal", game_over)
	
	for child in hearts_parent.get_children():
		hearts_list.append(child)
		
	if not honeyed_buff_timer:
		honeyed_buff_timer = Timer.new()
		honeyed_buff_timer.one_shot = true
		add_child(honeyed_buff_timer)
		
	if not appled_buff_timer:
		appled_buff_timer = Timer.new()
		appled_buff_timer.one_shot = true
		add_child(appled_buff_timer)
		
	if not fired_buff_timer:
		fired_buff_timer = Timer.new()
		fired_buff_timer.one_shot = true
		add_child(fired_buff_timer)
	
	if not crowned_buff_timer:
		crowned_buff_timer = Timer.new()
		crowned_buff_timer.one_shot = true
		add_child(crowned_buff_timer)
		
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		is_jumping = false
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			start_jump()
		elif double_jump:
			start_jump()
			double_jump = false
	
	if is_jumping:
		if Input.is_action_pressed("ui_accept"):
			jump_time += delta
			if jump_time <= MAX_JUMP_TIME:
				velocity.y = JUMP_FORCE
			else:
				end_jump()
		else:
			end_jump()
			
	$StatusEffects/DoubleJump.visible = double_jump
	
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		drop_through = true
		$CollisionShape2D.set_deferred("disabled", true)  # Disable collision safely
		drop_timer = DROP_DELAY
	
	# Count down the drop timer
	if drop_timer > 0:
		drop_timer -= delta
	
	# Re-enable collision after the delay or when no longer falling
	if drop_through and (drop_timer <= 0 or velocity.y == 0):
		$CollisionShape2D.set_deferred("disabled", false)
		drop_through = false
	
	move_and_slide()

func start_jump():
	velocity.y = JUMP_FORCE
	is_jumping = true
	jump_time = 0

func end_jump():
	is_jumping = false
	if velocity.y < 0:
		velocity.y *= JUMP_CUT

func _on_body_entered(body):
	print(body.name)
	match body.name:
		
		"Bear":
			if(is_honeyed):
				emit_signal("kill_score_signal", KILL_SCORE)
			elif(is_sworded):
				emit_signal("kill_score_signal", KILL_SCORE)
				end_sworded()
			else:
				take_damage(1)
			emit_signal("delete_body_signal", body)
			
		"Bush":
			if(is_appled):
				emit_signal("kill_score_signal", KILL_SCORE)
			else:
				take_damage(1)
			emit_signal("delete_body_signal", body)
		
			
		"Honey":
			heal(1)
			honeyed()
			emit_signal("delete_body_signal", body)
			
		"Apple":
			appled()
			emit_signal("delete_body_signal", body)
		
			
		"Fire":
			take_damage(1)
			fired()
			emit_signal("delete_body_signal", body)
		
		"DragonFire":
			take_damage(1)
			fired()
			emit_signal("delete_body_signal", body)
		
			
		"Knight":
			
			if(is_crowned):
				emit_signal("kill_score_signal", KILL_SCORE)
			
			elif(is_sworded):
				emit_signal("kill_score_signal", KILL_SCORE)
				end_sworded()
				
			else:
				take_damage(1)
			emit_signal("delete_body_signal", body)
		
		"Sword":
			
			if(is_crowned):
				emit_signal("kill_score_signal", KILL_SCORE)
			
			elif(is_sworded):
				emit_signal("kill_score_signal", KILL_SCORE)
				end_sworded()
				
			else:
				take_damage(1)
			emit_signal("delete_body_signal", body)
			
		"SwordBuff":
			sworded()
			emit_signal("delete_body_signal", body)
		
		"Crown":
			crowned()
			emit_signal("delete_body_signal", body)
		
			
	
func take_damage(amount: int):
	
	health -= amount + (1 if is_fired else 0)
	update_heart_display()
	if health <= 0:
		health = 3
		died_signal.emit()

func heal(amount: int):
	if(health + amount < MAX_HEALTH):
		health += amount
	else:
		health = MAX_HEALTH
	update_heart_display()
	
func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
		
func new_game():
	update_heart_display()

func game_over():
	end_appled()
	end_appled()
	end_fired()
	end_sworded()
	
	
	
func honeyed():
	is_honeyed = true
	$StatusEffects/Honeyed.visible = true

	if honeyed_buff_timer.is_stopped() == false:
		honeyed_buff_timer.stop()

	honeyed_buff_timer.start(BUFF_DURATION)

	if not honeyed_buff_timer.is_connected("timeout", Callable(self, "end_honeyed")):
		honeyed_buff_timer.connect("timeout", Callable(self, "end_honeyed"))

func end_honeyed():
	is_honeyed = false
	$StatusEffects/Honeyed.set_deferred("visible", false)
	
func fired():
	is_fired = true
	$StatusEffects/Fired.visible = true

	if fired_buff_timer.is_stopped() == false:
		fired_buff_timer.stop()

	fired_buff_timer.start(BUFF_DURATION)

	if not fired_buff_timer.is_connected("timeout", Callable(self, "end_fired")):
		fired_buff_timer.connect("timeout", Callable(self, "end_fired"))

func end_fired():
	print("Hello, World!")
	is_fired = false
	$StatusEffects/Fired.set_deferred("visible", false)
	
func appled():
	is_appled = true
	$StatusEffects/Appled.set_deferred("visible", true)
	double_jump = true
	
	
	if appled_buff_timer.is_stopped() == false:
		appled_buff_timer.stop()

	appled_buff_timer.start(BUFF_DURATION)

	if not appled_buff_timer.is_connected("timeout", Callable(self, "end_appled")):
		appled_buff_timer.connect("timeout", Callable(self, "end_appled"))

func end_appled():
	is_appled = false
	$StatusEffects/Appled.visible = false
	
func sworded():
	is_sworded = true
	$StatusEffects/Sworded.set_deferred("visible", true)

func end_sworded():
	is_sworded = false
	$StatusEffects/Sworded.visible = false
	
func crowned():
	is_crowned = true
	$StatusEffects/Crowned.set_deferred("visible", true)
	
	if crowned_buff_timer.is_stopped() == false:
		crowned_buff_timer.stop()

	crowned_buff_timer.start(BUFF_DURATION)

	if not crowned_buff_timer.is_connected("timeout", Callable(self, "end_crowned")):
		crowned_buff_timer.connect("timeout", Callable(self, "end_crowned"))

func end_crowned():
	is_crowned = false
	$StatusEffects/Crowned.visible = false
