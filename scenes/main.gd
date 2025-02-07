extends Node

#preload obstacles
var bear_scene = preload("res://scenes/bear.tscn")
var bush_scene = preload("res://scenes/bush.tscn")
var obstacle_types := [bear_scene, bush_scene]
var obstacles : Array

#game variables
const Player_POS := Vector2i(200, 510)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : float
const SCORE_MODIFIER : float = 40
var high_score : int
const OBSTACLE_SPEED : float = 6.0  # Constant speed for obstacles
var screen_size : Vector2i
var game_running : bool
var last_obs
var spawn_speed: float = 3.0  # Time between spawns in seconds
var spawn_timer: float = 0.0

func _ready():
	Engine.max_fps = 120
	screen_size = get_window().size
	$GameOver.get_node("Button2").pressed.connect(new_game)
	$GameOver.get_node("Button").pressed.connect(restart_game)
	$HUD.get_node("Button").pressed.connect(start_game)
	$Player.connect("died", game_over)
	$Player.connect("delete_body", remove_obs)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Player.position = Player_POS
	$Player.velocity = Vector2i(0, 0)
	
	$HUD.get_node("Button").show()
	$HUD.get_node("BlackBackground").show()
	$GameOver.hide()

func _process(delta):
	print(Engine.get_frames_per_second())
	if game_running:
		# Update spawn timer
		spawn_timer += delta
		
		# Handle obstacle spawning
		if spawn_timer >= spawn_speed:
			generate_obs()
			spawn_timer = 0.0  # Reset timer
		
		
		# Move obstacles at constant speed
		for obs in obstacles:
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

func generate_obs():
	var obs_type = obstacle_types[randi() % obstacle_types.size()]
	var obs = obs_type.instantiate()
	var obs_height = obs.get_node("Sprite2D").texture.get_height()
	var obs_scale = obs.get_node("Sprite2D").scale
	var obs_x : int = screen_size.x
	var obs_y : int = Player_POS.y + 5  # Align with Player's feet
	last_obs = obs
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


func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
