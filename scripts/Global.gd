# Global.gd
extends Node

var high_score = 0
var save_path = "user://variable.save"

func reset_high_score():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(high_score)
	high_score = 0
	print("High score has been reset!")
