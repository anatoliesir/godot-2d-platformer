extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal transition_finished
signal transition_almost_finished

func scene_transition(to_scene_directory: String) -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(to_scene_directory)
	transition_almost_finished.emit()
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	transition_finished.emit()


func normal_transition() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	transition_almost_finished.emit()
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	transition_finished.emit()
