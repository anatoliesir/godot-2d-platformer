extends Node2D

var last_index: int = -1
var random_index: int

var backgrounds = [
	preload("res://Scenes/Parallax/blue_parallax.tscn"),
	preload("res://Scenes/Parallax/brown_parallax.tscn"),
	preload("res://Scenes/Parallax/gray_parallax.tscn"),
	preload("res://Scenes/Parallax/green_parallax.tscn"),
	preload("res://Scenes/Parallax/pink_parallax.tscn"),
	preload("res://Scenes/Parallax/purple_parallax.tscn"),
	preload("res://Scenes/Parallax/yellow_parallax.tscn")
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_randomized_parallax_background()
	last_index = random_index

func show_randomized_parallax_background() -> void:
	# Sterg fiecare copil
	for child in get_children():
		child.queue_free()
	
	# Aleg alt background parallax
	while last_index == random_index:
		random_index = randi() % backgrounds.size()
	
	last_index = random_index
	var bg_instance = backgrounds[random_index].instantiate()
	add_child(bg_instance)
