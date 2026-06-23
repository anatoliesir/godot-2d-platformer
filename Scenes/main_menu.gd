extends Control

# Folosim clasa SceneTransition din scena scene_transition
func _on_play_pressed() -> void:
	SceneTransition.scene_transition("res://Main.tscn")
	


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
