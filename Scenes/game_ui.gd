extends Control

var main_character
@onready var background_holder: Node2D = $"../../ParallaxBackground/background_holder"
@onready var level_container: LevelContainer = $"../../level_container"
@onready var next_button: Button = $HBoxContainer/Next
@onready var previous_button: Button = $HBoxContainer/Previous

func _ready() -> void:
	await get_tree().process_frame
	var level_index = level_container.get_current_level_index()
	var next_level_file: String = "res://Scenes/Levels/level_" + str(level_index + 1) + ".tscn"
	var previous_level_file: String = "res://Scenes/Levels/level_" + str(level_index - 1) + ".tscn"
	
	if !FileAccess.file_exists(next_level_file):
		next_button.visible = false
	if !FileAccess.file_exists(previous_level_file):
		previous_button.visible = false

func _on_reload_pressed() -> void:
	SceneTransition.normal_transition()
	await SceneTransition.transition_almost_finished
	
	main_character = get_tree().get_first_node_in_group("main_character")
	
	main_character.despawn_function("normal")
	background_holder.show_randomized_parallax_background()
	main_character.spawn_function()


func _on_next_pressed() -> void:
	SceneTransition.normal_transition()
	await SceneTransition.transition_almost_finished
	
	var level_index = level_container.get_current_level_index() + 1
	var level_file: String = "res://Scenes/Levels/level_" + str(level_index) + ".tscn"
	var temporar_level_file: String = "res://Scenes/Levels/level_" + str(level_index + 1) + ".tscn"
	
	if !FileAccess.file_exists(temporar_level_file):
		next_button.visible = false
		previous_button.visible = true
	else:
		previous_button.visible = true
	
	level_container.load_level(level_file)
	
	main_character = get_tree().get_first_node_in_group("main_character")
	
	main_character.despawn_function("normal")
	background_holder.show_randomized_parallax_background()
	main_character.spawn_function()


func _on_previous_pressed() -> void:
	SceneTransition.normal_transition()
	await SceneTransition.transition_almost_finished
	
	var level_index = level_container.get_current_level_index() - 1
	var level_file: String = "res://Scenes/Levels/level_" + str(level_index) + ".tscn"
	var temporar_level_file: String = "res://Scenes/Levels/level_" + str(level_index - 1) + ".tscn"
	
	if !FileAccess.file_exists(temporar_level_file):
		previous_button.visible = false
		next_button.visible = true
	else:
		next_button.visible = true
	
	level_container.load_level(level_file)
	
	main_character = get_tree().get_first_node_in_group("main_character")
	
	main_character.despawn_function("normal")
	background_holder.show_randomized_parallax_background()
	main_character.spawn_function()
