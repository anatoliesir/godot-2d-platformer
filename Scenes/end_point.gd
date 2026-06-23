extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
var main_character

func _on_body_entered(body: Node2D) -> void:
	main_character = get_tree().get_first_node_in_group("main_character")
	if !body.is_in_group("main_character"): return
	
	animated_sprite_2d.play("pressed")
	
	if !main_character:
		print_debug("Eroare!!!")
		return
	
	# Fac ca main_character sa sara in aer si sa dispara
	main_character.despawn_function("trophy")
