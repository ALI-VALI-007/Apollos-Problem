class_name interact extends Node2D

@export var interact_val = "none"
@export var interact_label = "none"
@export var interact_type = "none"
@export var coords: Vector2

func _ready():
	var parent_node = get_parent()
	coords = parent_node.position
