extends CharacterBody2D

@onready var health : int = 250
@export var move_speed : float = 75
@onready var animation_tree=$AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var all_interactions = []
@onready var interact_label = $Interact/InteractName

# Movement funcs
func _ready():
	animation_tree.set("parameters/Idle/blend_position", 1)

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	velocity = input_direction * move_speed
	update_animation_params((velocity))
	move_and_slide()
	pick_state()
	#print("walk")
	
func _process(delta):
	check_interact_type()

func update_animation_params(move_input: Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

func pick_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")



#Interaction funcs
func _on_interact_area_area_entered(area):
	all_interactions.insert(0,area)
	update_interactions_label()

func _on_interact_area_area_exited(area):
	all_interactions.erase(area)
	update_interactions_label()

func update_interactions_label():
	if all_interactions:
		interact_label.text = all_interactions[0].interact_label
	else:
		interact_label.text = ""

#Add the if statement and call to the interact types func basically
func check_interact_type():
	if not all_interactions:
		return
	var interact_types = all_interactions[0].interact_type
	if interact_types == "heal" and Input.is_action_pressed("Interact"):
		heal()
		#print("heals")
	for interaction in all_interactions:
		if interaction.interact_type == "black_hole":
			black_hole()
			#print("RUNS")
			break
	if interact_types == "EndGame" and Input.is_action_pressed("Interact"):
		endGame()

func heal():
	health+=all_interactions[0].interact_val.to_int()
	#print(health)
	if health > 250:
		health = 250
	var health_bar_node = get_node("O2Level")
	health_bar_node.update_health(health)

func damage():
	health-=all_interactions[0].interact_val.to_int()
	var health_bar_node = get_node("O2Level")
	health_bar_node.update_health(health)
	if health < 0: #trigger game over stuff
		get_tree().change_scene_to_file("res://MainMenu.tscn")

func black_hole():
	var blackhole_coords = all_interactions[0].coords
	var cur_coords = position
	var direction = (blackhole_coords-position).normalized()
	var speed = 0.7
	var velocity = direction * speed
	move_and_collide(velocity)
	damage()

func endGame():
	get_tree().quit()
