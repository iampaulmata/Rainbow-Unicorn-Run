extends Node

var save_path = "user://variable.save"

#preload obstacles
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var boulder_scene = preload("res://scenes/boulder.tscn")
var obstacle_types := [stump_scene, rock_scene, boulder_scene]
var obstacles : Array


#preload items
var taco_scene = preload("res://scenes/taco.tscn")
var heart_scene = preload("res://scenes/heart.tscn")
var item_types := [taco_scene, heart_scene]
var item : Array
var item_heights := [200, 390]

const UNICORN_START_POS := Vector2i(180, 400)
const CAM_START_POS := Vector2i(960, 540)
var score : int
const SCORE_MODIFIER : int = 10
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var high_score : int
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	#reset variables and load high score if it exists
	score = 0
	show_score()
	load_data()
	game_running = false
	get_tree().paused = false
	#difficulty = 0
	
	#reset all obstacles
	for obs in obstacles:
		obs.queue_free()
		obstacles.clear()
	
	#reset the nodes
	$Unicorn.position = UNICORN_START_POS
	$Unicorn.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED :
			speed = MAX_SPEED
			
		generate_obs()
		
		$Unicorn.position.x += speed
		$Camera2D.position.x += speed
		
		#update score
		score += speed
		show_score()
		
		#udpate ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
			for obs in obstacles:
				if obs.position.x < ($Camera2D.position.x - screen_size.x):
					remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		obs = obs_type.instantiate()
		var obs_height = obs.get_node("Sprite2D").texture.get_height()
		var obs_scale = obs.get_node("Sprite2D").scale
		var obs_x : int = screen_size.x + score + 100
		var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Unicorn":
		game_over()
		
func game_over():
	check_high_score()
	save()
	get_tree().paused = true
	game_running = false
	$GameOver.show()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)
		
func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(high_score)
	print("high score saved")
func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		high_score = file.get_var(high_score)
		print(high_score)
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)
	else:
		print("No data saved...")
		high_score = 0
