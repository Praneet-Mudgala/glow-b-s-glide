# Here is the main code that runs the entire game.

#

extends Node

var lives = 3
var death_lives = 0
var hs_mod = 10.0
var urchin_scene = preload("res://scenes/urchin.tscn")
var pufferfish_scene = preload("res://scenes/pufferfish.tscn")
var vent_scene = preload("res://scenes/vent.tscn")
var obstacle_types := [urchin_scene]
var obstacles : Array
var pufferfish_heights := [350,400]

const GLOWB_START_POS := Vector2i(100, 170)
const CAM_START_POS := Vector2i(640, 360)
var score : int
var high_score : int

var difficulty
const MAX_DIFFICULTY : int = 2

var speed : int
const START_SPEED : float = 9.0
const MAX_SPEED : int = 25

var screen_size : Vector2i
var ground_height : int
var game_running : bool

var last_obs





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()


func new_game():
	$GlowB.reset_player()
	lives = 3
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()
	obstacles.clear()
	$HUD.get_node("LivesLabel").text = "Lives: " + str(lives)
	$GlowB.position = GLOWB_START_POS
	$GlowB.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,0)
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	if game_running:
		@warning_ignore("narrowing_conversion", "integer_division")
		speed = START_SPEED + score / 7500
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		generate_obs()
		
		
		$GlowB.position.x += speed
		$Camera2D.position.x += speed
			
		score += speed
		show_score()
			
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		for obs in obstacles:
			if is_instance_valid(obs):
				if obs.position.x < ($Camera2D.position.x - screen_size.x):
					remove_obs(obs)
			
	else:
		if Input.is_action_pressed("ui_accept"):
			new_game()
			game_running = true
			$HUD.get_node("StartLabel").hide()


func show_score():
	@warning_ignore("integer_division")
	$HUD.get_node("ScoreLabel").text = "Score: " + str(score / 10)
	
	
func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(100,500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100) + randi_range(1, 50)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 70
			last_obs = obs
			obs.position = Vector2i(obs_x, obs_y)
			add_child(obs)
			obstacles.append(obs)
			add_obs(obs, obs_x, obs_y)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = pufferfish_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = pufferfish_heights[randi() % pufferfish_heights.size()] + 130
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	# add_child(obs)
	obstacles.append(obs)

func hit_obs(body):
	if body.name == "GlowB":
		if lives > death_lives:
			lives -= 1
			$HUD.get_node("LivesLabel").text = "Lives: " + str(lives)
			$GlowB.play_damaged()
			if lives == death_lives:
				$GlowB.play_death()
				game_over()
		else:
			$GlowB.play_death()
			game_over()

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func adjust_difficulty():
	@warning_ignore("integer_division")
	difficulty = score / 5000
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "Highscore: " + str(round(high_score / hs_mod))
