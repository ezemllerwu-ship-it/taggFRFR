extends Node2D

@onready var player = load("res://scene/player.tscn")

@onready var room_1 = load("res://scene/room_1.tscn")
@onready var room_2 = load("res://scene/room_2.tscn")

var spawn_position
var wanted_room

func _ready() -> void:
	wanted_room = room_1
	spawn_room()
	spawn_player()

func spawn_room():
	var top_node = $"."
	var room = wanted_room.instantiate()
	top_node.add_child(room)



func spawn_player():
	var player = player.instantiate()
	add_child(player)
	player.global_position = spawn_position

func set_spawn(spawn):
	spawn_position = spawn

func set_wanted_room(wanted):
	wanted_room = wanted

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
