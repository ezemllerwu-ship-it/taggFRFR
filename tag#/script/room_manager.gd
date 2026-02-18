extends Node2D

@onready var player = load("res://scene/player.tscn")
@onready var room_manager = $"."
@onready var room_1 = load("res://scene/room_1.tscn")
@onready var room_2 = load("res://scene/room_2.tscn")
var room_string = "res://scene/room_"
var spawn_position
var wanted_room = 0

func spawn_room():
	wanted_room += 1
	var room = load(room_string + str(wanted_room) + ".tscn").instantiate()
	room_manager.add_child(room)
	spawn_player()

func spawn_player():
	var player_instince = player.instantiate()
	add_child(player_instince)
	player_instince.global_position = spawn_position

func reset():
	for n in room_manager.get_children():
		room_manager.remove_child(n)
		n.queue_free()

func kill():
		var player_instince = get_node("player")
		room_manager.remove_child(player_instince)
		player.queue_free()
		spawn_player()

func dash_refill():
	var player_instince = get_node("player")
	$player.dash_refill()

func set_spawn(spawn):
	spawn_position = spawn
