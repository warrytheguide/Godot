extends Node

var obstacles : Array

@export var obstacle_types: Array[Resource] = []

#game variables
const Player_POS := Vector2i(200, 510)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : float
const SCORE_MODIFIER : float = 40
var high_score : int
const OBSTACLE_SPEED : float = 5.0  # Constant speed for obstacles
var screen_size : Vector2i
var game_running : bool
var last_obs
var spawn_speed: float = 3.0  # Time between spawns in seconds
var spawn_timer: float = 0.0

signal new_game_signal
signal game_over_signal

func _ready():
	Engine.max_fps = 120
	screen_size = get_window().size
	$GameOver.get_node("Button2").pressed.connect(new_game)
	$GameOver.get_node("Button").pressed.connect(restart_game)
	$HUD.get_node("Button").pressed.connect(start_game)
	$Player.connect("died_signal", game_over)
	$Player.connect("delete_body_signal", remove_obs)
	$Player.connect("kill_score_signal", kill_score)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	new_game_signal.emit()
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Player.position = Player_POS
	$Player.velocity = Vector2i(0, 0)
	
	$HUD.get_node("Button").show()
	$HUD.get_node("BlackBackground").show()
	$GameOver.hide()

func _process(delta):
	
	if game_running:
		# Update spawn timer
		spawn_timer += delta
		
		# Handle obstacle spawning
		if spawn_timer >= spawn_speed:
			generate_obs()
			spawn_timer = 0.0  # Reset timer
		
		
		# Move obstacles at constant speed
		for obs in obstacles:
			if not obs.has_node("Bat"):
				obs.position.x -= OBSTACLE_SPEED
				
		score += SCORE_MODIFIER/100
		show_score()
		
		# Remove off-screen obstacles
		for obs in obstacles:
			if obs.position.x < -100:
				remove_obs(obs)

func restart_game():
	new_game()
	start_game()

func start_game():
	game_running = true
	$HUD.get_node("Button").hide()
	$HUD.get_node("BlackBackground").hide()
	
func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	emit_signal("game_over_signal")

func generate_obs():
	var obs_type = obstacle_types[randi() % obstacle_types.size()]
	var obs = obs_type.instantiate()
	var obs_height = obs.get_node("Sprite2D").texture.get_height()
	var obs_scale = obs.get_node("Sprite2D").scale
	var obs_x : int = screen_size.x
	var obs_y : int = Player_POS.y + 5  # Align with Player's feet
	last_obs = obs
	
	if obs.has_node("Bat"):
		obs.connect("hit_player", Callable(self, "_on_bat_hit_player"))
	
	add_obs(obs, obs_x, obs_y)
	

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	# Remove this line as we're handling collision through the player's Area2D
	# obs.body_entered.connect(hit_obs)  
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)


func show_score():
	$HUD.get_node("ScoreLabel").text = str(int(round(score)))

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func kill_score(amount: float):
	score += amount
	
func _on_bat_hit_player():
	$Player.take_damage(1)
