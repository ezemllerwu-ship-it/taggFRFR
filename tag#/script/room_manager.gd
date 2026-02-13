extends Node2D

@onready var player = load("res://scene/player.tscn")
@onready var room_manager = $"."
@onready var room_1 = load("res://scene/room_1.tscn")
@onready var room_2 = load("res://scene/room_2.tscn")
var room_string = "res://scene/room_"

var spawn_position
var wanted_room = 0

func _ready() -> void:
	spawn_room()
	
func spawn_room():
	wanted_room += 1
	var room = load(room_string + str(wanted_room) + ".tscn").instantiate()
	room_manager.add_child(room)
	spawn_player()
	print_tree_pretty()


func spawn_player():
	var player_instance = player.instantiate()
	add_child(player_instance)
	player_instance.global_position = spawn_position

func reset():
	for n in room_manager.get_children():
		room_manager.remove_child(n)
		n.queue_free()

func set_spawn(spawn):
	spawn_position = spawn

#func set_wanted_room(wanted):
	#wanted_room = wanted

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
