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

func reset_room_manager():
	for n in get_children():
		n.queue_free()

func spawn_player():
	if is_instance_valid(current_player):
		current_player.queue_free()
	
	current_player = player_scene.instantiate()
	add_child(current_player)
	current_player.global_position = spawn_position

func kill():
	if !is_instance_valid(current_player): return
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1.0
	current_player.visible = false
	current_player.set_physics_process(false)
	await get_tree().create_timer(0.2).timeout
	spawn_player()

func dash_refill():
	if is_instance_valid(current_player):
		current_player.has_dash = true
		if current_player.has_method("on_dash_refill"):
			current_player.on_dash_refill()

func set_spawn(pos: Vector2):
	spawn_position = pos
