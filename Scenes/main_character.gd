extends CharacterBody2D


const SPEED: float = 150
const ACCELERATION: float = 10
const JUMP_VELOCITY: float = -330

# Daca valoarea e mai mare, atunci alunecarea va fi mai rapida
const WALL_SlIDE_GRAVITY_DIFFERENCE = 7
const WALL_JUMP_PUSH = 250

# Variabile booleane
var jumped: bool = false
var double_jumped: bool = false
var is_wall_sliding: bool = false
var is_falling: bool = false
var running_cooldown: bool = false
var can_control: bool = true
var gravity_exists: bool = true
var stop_jump_particle: bool = false

# Este un nod de animatie de caracter
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Sunt noduri de pentru efecte de particule GPU
@onready var run_left_particles: GPUParticles2D = $particles/run_left_particles
@onready var run_right_particles: GPUParticles2D = $particles/run_right_particles
@onready var land_left_particles: GPUParticles2D = $particles/land_left_particles
@onready var land_right_particles: GPUParticles2D = $particles/land_right_particles
@onready var jump_particles: GPUParticles2D = $particles/jump_particles

var checkpoint = null
var max_y_velocity: float = 0.0

func _ready() -> void:
	despawn_function("normal")
	spawn_function()



func _physics_process(delta: float) -> void:
	if !can_control: 
		if !gravity_exists: return
		
		gravity_function(delta)
		move_and_slide()
		return
	
	if gravity_exists: gravity_function(delta)
	
	# Aceasta se va reseta in alta functie(particles_function)
	if max_y_velocity < velocity.y: max_y_velocity = velocity.y
	
	# Aflu directia inspre care merge jucatorul
	var direction := Input.get_axis("left", "right")
	
	# Toate functiile date sunt pentru ca personajul sa fie capabil de toate
	normal_jump_function()
	
	double_jump_function()
	
	wall_jump_function()
	
	wall_slide_function(delta)
	
	running_and_idle_function(direction)
	
	horizontal_flip()
	
	particles_function()
	
	# pun fizica in miscare
	move_and_slide()




# Adaug gravitatea si animatia "fall"
# Gravitatea este setata in project physics settings
func gravity_function(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if velocity.y > 0:
			is_falling = true
			animated_sprite_2d.play("fall")
			
	else:
		is_falling = false


# Saritura obisnuita(jump)
func normal_jump_function() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumped = true
		animated_sprite_2d.play("jump")
	elif is_on_floor():
		jumped = false
		double_jumped = false


func double_jump_function() -> void:
	# Verific daca pot face saritura in aer(double_jump)
	if Input.is_action_just_pressed("jump") && !is_on_floor() && jumped && !double_jumped:
		velocity.y = JUMP_VELOCITY
		double_jumped = true
		animated_sprite_2d.play("double_jump")
	# Saritura in aer
	elif Input.is_action_just_pressed("jump") && !is_on_floor() && !jumped && !double_jumped:
		velocity.y = JUMP_VELOCITY
		jumped = true
		double_jumped = true
		animated_sprite_2d.play("double_jump")

# Alunecare pe perete
func wall_slide_function(delta: float) -> void:
	if is_on_wall_only() && velocity.y > 0:
		velocity.y = get_gravity().y * delta * WALL_SlIDE_GRAVITY_DIFFERENCE
		animated_sprite_2d.play("wall_slide")
		jumped = true
		is_wall_sliding = true
	else:
		is_wall_sliding = false


# Aceasta functie trebuie sa fie OBLIGATORIU inainte de wall_slide_function
# deoarece is_wall_sliding va fi fals intotdeauna!!
func wall_jump_function() -> void:
	if Input.is_action_just_pressed("jump") && is_wall_sliding:
		is_wall_sliding = false
		running_cooldown = true
		if animated_sprite_2d.flip_h:
			velocity.x = WALL_JUMP_PUSH
		else:
			velocity.x = -WALL_JUMP_PUSH
		
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("jump")
		double_jumped = false


# Direction este un float, ce verifica daca noi mergem la dreapta sau stanga.
# El afla aceasta prin get_axis, ce este prescurtare a unei functii mai lungi
func running_and_idle_function(direction: float) -> void:
	# Acest cooldown este doar pentru wall_jump_function
	if running_cooldown:
		running_cooldown = false
		return
	
	
	if direction:
		if direction < 0:
			velocity.x = max(velocity.x - ACCELERATION, -SPEED)
		else:
			velocity.x = min(velocity.x + ACCELERATION, SPEED)
		
		# Animatia "run" si dust particle
		if (is_on_floor() && !jumped && !double_jumped):
			animated_sprite_2d.play("run")
	else:
		# Dupa ce am terminat sa apasam dreapta sau stanga, aceasta va avea un moment
		# de alunecare: de la valoarea velocity.x, pana la viteza 0, un pas fiind 40
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
		
		# Animatia "idle"
		if (is_on_floor() && !jumped && !double_jumped):
			animated_sprite_2d.play("idle")


func horizontal_flip() -> void:
	# Intorc orizontal personajul
	if (velocity.x < -1): 
		animated_sprite_2d.flip_h = true
	elif (velocity.x > 1):
		animated_sprite_2d.flip_h = false


func spawn_function() -> void:
	await SceneTransition.transition_finished
	gravity_exists = false
	can_control = false
	visible = true
	
	# Aceasta initializare ESTE OBLIGATORIE
	checkpoint = get_tree().get_first_node_in_group("checkpoint")
	
	global_position = checkpoint.global_position
	animated_sprite_2d.play("appearing")
	
	await animated_sprite_2d.animation_finished
	set_process_input(true)
	gravity_exists = true
	can_control = true

func despawn_function(type: String) -> void:
	
	set_process_input(false)
	if type == "trophy":
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("jump")
		
		# Verific daca cade
		is_falling = false
		while !is_falling:
			await get_tree().process_frame
		
		gravity_exists = false
		can_control = false
		animated_sprite_2d.play("disappearing")
		await animated_sprite_2d.animation_finished
	elif type == "normal":
		gravity_exists = false
		can_control = false
	else:
		print_debug("Eroare despawn_function!!!")
		return
	
	visible = false

func particles_function() -> void:
	# Particule la fugire
	if is_on_floor_only() && velocity.x != 0: 
		if velocity.x > 0: run_right_particles.emitting = true
		else: run_left_particles.emitting = true
		
	elif run_left_particles.emitting || run_right_particles.emitting: 
		run_left_particles.emitting = false
		run_right_particles.emitting = false
	
	# Particule la cadere
	if is_on_floor() && max_y_velocity > 150:
		land_left_particles.restart()
		land_right_particles.restart()
		land_left_particles.emitting = true
		land_right_particles.emitting = true
		
		max_y_velocity = 0
	
	# Particule la saritura(saritura normala si double)
	if Input.is_action_just_pressed("jump") && (jumped || double_jumped) && !stop_jump_particle:
		jump_particles.restart()
		jump_particles.emitting = true
		
		if jumped && double_jumped:
			stop_jump_particle = true
		
	elif is_on_floor() || is_wall_sliding:
		stop_jump_particle = false
