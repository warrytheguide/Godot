extends Node

var obstacles : Array

@export var spawner_one: Array[Resource] = []
@export var spawner_two: Array[Resource] = []
@export var spawner_three: Array[Resource] = []


const Player_POS := Vector2i(200, 510)
var score : float
var high_score : int

var screen_size : Vector2i
var game_running : bool
var last_obs
var spawn_speed: float = 1.7
var spawn_timer: float = 0.0
var game_phase = 1

const OBSTACLE_SPEED : float = 5.7
const SCORE_MODIFIER : float = 40
const PHASE_TWO_SCORE = 1000
const PHASE_THREE_SCORE = 2000
const PHASE_FOUR_SCORE = 3000

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
	$Background/Forest.set_deferred("visible", true)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	new_game_signal.emit()
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Player.position = Player_POS
	$Player.velocity = Vector2i(0, 0)
	
	$HUD.get_node("Button").show()
	$HUD.get_node("BlackBackground").show()
	$GameOver.hide()
	
	$Platform1.set_process_mode(Node.PROCESS_MODE_DISABLED)
	$Platform1.visible = false
	$Platform2.set_process_mode(Node.PROCESS_MODE_DISABLED)
	$Platform2.visible = false

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
			if not obs.is_in_group("alt_speed"):
				obs.position.x -= OBSTACLE_SPEED
				
		score += SCORE_MODIFIER/100
		show_score()
		
		# Remove off-screen obstacles
		for obs in obstacles:
			if obs.position.x < -100:
				remove_obs(obs)
				
	if(score > PHASE_FOUR_SCORE):
		hardmode()
		match int(fmod(score / 1000, 3)):
			0:
				game_phase = 1
				$Platform1.set_process_mode(Node.PROCESS_MODE_DISABLED)
				$Platform1.visible = false
				$Platform2.set_process_mode(Node.PROCESS_MODE_DISABLED)
				$Platform2.visible = false
				$Background/Hell.set_deferred("visible", false)
				$Background/Forest.set_deferred("visible", true)
			1:
				game_phase = 2
				$Platform1.set_process_mode(Node.PROCESS_MODE_INHERIT)
				$Platform1.visible = true
				$Background/Forest.set_deferred("visible", false)
				$Background/Castle.set_deferred("visible", true)
			2:
				game_phase = 3
				$Platform2.set_process_mode(Node.PROCESS_MODE_INHERIT)
				$Platform2.visible = true
				$Background/Castle.set_deferred("visible", false)
				$Background/Hell.set_deferred("visible", true)
				
	elif(score > PHASE_THREE_SCORE):
		game_phase = 3
		$Platform2.set_process_mode(Node.PROCESS_MODE_INHERIT)
		$Platform2.visible = true
		$Background/Castle.set_deferred("visible", false)
		$Background/Hell.set_deferred("visible", true)
	
	elif (score > PHASE_TWO_SCORE):
		game_phase = 2
		$Platform1.set_process_mode(Node.PROCESS_MODE_INHERIT)
		$Platform1.visible = true
		$Background/Forest.set_deferred("visible", false)
		$Background/Castle.set_deferred("visible", true)
		
func restart_game():
	new_game()
	start_game()

func start_game():
	game_phase = 1
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
	
	var obs_type
	match game_phase:
		1:
			obs_type = spawner_one[randi() % spawner_one.size()]
		2:
			obs_type = spawner_two[randi() % spawner_two.size()]
		3:
			obs_type = spawner_three[randi() % spawner_three.size()]
			
	var obs = obs_type.instantiate()
	var obs_height = obs.get_node("Sprite2D").texture.get_height()
	var obs_scale = obs.get_node("Sprite2D").scale
	var obs_x : int = screen_size.x
	var obs_y : int = Player_POS.y - 10
	last_obs = obs
	
	if obs.has_node("Bat"):
		obs.connect("hit_player", Callable(self, "_on_hit_player"))
	elif obs.has_node("Dragon"):
		obs.connect("hit_player", Callable(self, "_on_hit_player"))
		obs.connect("spawn_obs", Callable(self, "add_obs"))
	elif obs.has_node("Knight"):
		obs.connect("spawn_obs", Callable(self, "add_obs"))
		
	add_obs(obs, obs_x, obs_y)
	

func add_obs(obs, x, y):
	if(obs.has_node("Sword")):
		y = $Player.position.y - 50
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

func hardmode():
	pass

func kill_score(amount: float):
	score += amount
	
func _on_hit_player():
	$Player.take_damage(1)
