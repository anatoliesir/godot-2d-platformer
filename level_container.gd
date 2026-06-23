extends Node2D
class_name LevelContainer

var current_level = null

# Incarc nivelul default
func _ready() -> void:
	load_level("res://Scenes/Levels/level_1.tscn")

func load_level(path: String) -> void:
	if current_level: 
		current_level.queue_free()
	
	current_level = load(path).instantiate()
	add_child(current_level)

func get_current_level_index() -> int:
	var level_file = current_level.scene_file_path
	var level_name = level_file.get_file().get_basename()
	var level_number = level_name.split("_")[1].to_int()
	return level_number
