# TitleScreen.gd
extends Control

var secret_code = ["r", "e", "s", "e", "t"]
var code_index = 0

# Function called when the Start button is pressed
func _on_start_button_pressed():
	print("Start button pressed")
	var scene_path = "res://scenes/main.tscn"
	if ResourceLoader.exists(scene_path, "PackedScene"):
		print("Scene exists: " + scene_path)
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Scene not found: " + scene_path)

# Connect the Start button's pressed signal to the function
func _ready():
	var start_button = $StartButton
	if start_button:
		start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
		print("StartButton connected")
	else:
		print("StartButton node not found")
		

func _input(event):
	if event is InputEventKey and event.pressed:
		var key_char = char(event.unicode)
		if key_char != "":
			key_char = key_char.to_lower()
			if key_char == secret_code[code_index]:
				code_index += 1
				if code_index == secret_code.size():
					Global.reset_high_score()
					code_index = 0
			else:
				code_index = 0
