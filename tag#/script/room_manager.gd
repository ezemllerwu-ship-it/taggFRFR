extends Node2D

@onready var player_scene = load("res://scene/player.tscn")
@onready var room_scene = load("res://scene/room_1.tscn")

var spawn_position: Vector2 = Vector2.ZERO
var current_player: CharacterBody2D

func spawn_room():
	reset_room_manager()
	var room = room_scene.instantiate()
	add_child(room)
	spawn_player()

func spawn_player():
	if is_instance_valid(current_player):
		current_player.queue_free()
	
	current_player = player_scene.instantiate()
	add_child(current_player)
	current_player.global_position = spawn_position

func reset_room_manager():
	for n in get_children():
		n.queue_free()

func kill():
	spawn_player()

func dash_refill():
	if is_instance_valid(current_player) and current_player.has_method("dash_refill"):
		current_player.dash_refill()
	else :
		print("fusk")
func set_spawn(pos: Vector2):
	spawn_position = pos
